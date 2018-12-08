//
//  MainABI+Read.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/6.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import ObjectMapper
import EthereumAddress

extension MainABI {
    
    public func readModel<T: Mappable>(method: String, parameters: [AnyObject] = [AnyObject](), options: TransactionOptions? = nil, type: T.Type, complete:((T?, [String: Any]?, Error?) -> Void)?) {
        self.readInfo(method: method, parameters: parameters, options: options) { (keyValues, error) in
            let model: T? = (keyValues != nil) ? type.init(JSON: keyValues!) : nil
            complete?(model, keyValues, error)
        }
    }
    
    public func readInfo(method: String, parameters: [AnyObject] = [AnyObject](), options: TransactionOptions? = nil, complete:(([String: Any]?, Error?) -> Void)?) {
        DispatchQueue.global().async {
            do {
                let value: [String: Any]! = try self.contract.read(method, parameters: parameters, transactionOptions: options)?.call()
                for item in value {
                    print("\(item)")
                }
                DispatchQueue.main.async { complete?(value,nil) }
            } catch {
                DispatchQueue.main.async { complete?(nil,error) }
                print(error)
            }
        }
    }
}

extension MainABI {
    // 用户信息
    // getInfo(address userAddress)
    class MainABI_UserInfo: Mappable {
        var registed: Bool = false  // 是否注册
        var infoHash: String? = nil // 信息哈希
        var orderCount: _BigUInt?   // 订单count
        var goodsCount: _BigUInt?   // 商品count
        
        required init?(map: Map) {}
        func mapping(map: Map) {
            registed <- map["registed"]
            infoHash <- map["infoHash"]
            orderCount <- (map["orderCount"], TransformOf<_BigUInt, Any>(fromJSON: { (value) -> _BigUInt? in
                return value as? _BigUInt
            }, toJSON: { (bigUInt) -> Any? in
                return bigUInt
            }))
            goodsCount <- (map["goodsCount"], TransformOf<_BigUInt, Any>(fromJSON: { (value) -> _BigUInt? in
                return value as? _BigUInt
            }, toJSON: { (bigUInt) -> Any? in
                return bigUInt
            }))
        }
    }
    
    public func getInfo(address: String, complete:((MainABI_UserInfo?, Error?) -> Void)?) {
        self.readModel(method: "getInfo", parameters: [address as AnyObject], type: MainABI_UserInfo.self) { (model, keyValues, error) in
            complete?(model,error)
        }
    }
}

extension MainABI {
    // 订单地址
    // function getOrders() public view returns (address[]) { return account.getOrders(msg.sender); }
    public func getOrders(sellerAddress: String, complete: (([EthereumAddress]?, Error?) -> Void)?) {
        var options: TransactionOptions = TransactionOptions.init()
        options.from = EthereumAddress(sellerAddress)
        self.readInfo(method: "getOrders", options: options) { (keyValues, error) in
            var res = [EthereumAddress]()
            if let kv = keyValues {
                for item in kv {
                    if let arr: [EthereumAddress] = item.value as? [EthereumAddress] {
                        res += arr
                    }
                }
            }
            complete?(res.isEmpty ? nil : res, error)
        }
    }
}

extension MainABI {
    // 订单信息
    // function getOrderInfo(address orderAddress)
    class MainABI_OrderInfo: PPS_ipfsModel {
        var orderAddress: String?   // 本调订单的地址
        var seller: EthereumAddress?         // 卖家地址
        var buyer: EthereumAddress?          // 买家地址
        var ipfsHash: String?       // 商品信息的哈希地址
        var price: _BigUInt?        // 商品价格
        var startTime: String?      // 订单开始时间，毫秒级
        var endTime: String?        // 订单结束时间，毫秒级
        var done: Bool = false      // 订单是否已完成
        var refund: Bool = false    // 是否申请退款
        var agreeRefund: Bool = false   // 是否同意退款
        
        override func mapping(map: Map) {
            orderAddress <- map["orderAddress"]
            seller <- map["seller"]
            buyer <- map["buyer"]
            ipfsHash <- map["ipfsHash"]
            price <- (map["price"], TransformOf<_BigUInt, _BigUInt>(fromJSON: { (value) -> _BigUInt? in
                return value
            }, toJSON: { (bigUInt) -> _BigUInt? in
                return bigUInt
            }))
            startTime <- map["startTime"]
            endTime <- map["endTime"]
            done <- map["done"]
            refund <- map["refund"]
            agreeRefund <- map["agreeRefund"]
        }
        func toJSON() -> [String : Any] {
            var json = [String: Any]()
            if let objc = self.orderAddress { json["orderAddress"] = objc }
            if let objc = self.seller { json["seller"] = objc }
            if let objc = self.buyer { json["buyer"] = objc }
            if let objc = self.ipfsHash { json["ipfsHash"] = objc }
            if let objc = self.price { json["price"] = objc }
            if let objc = self.startTime { json["startTime"] = objc }
            if let objc = self.endTime { json["endTime"] = objc }
            json["done"] = self.done
            json["refund"] = self.refund
            json["agreeRefund"] = self.agreeRefund
            return json
        }
    }
    // "0x58F811848fcD04103A06c388A284496166F1cd94"
    public func getOrderInfo(orderAddress: String, complete:(((MainABI_OrderInfo?, Error?) -> Void)?)) {
        self.readModel(method: "getOrderInfo", parameters: [orderAddress as AnyObject], type: MainABI_OrderInfo.self) { (model, keyValues, error) in
            model?.orderAddress = orderAddress
            complete?(model,error)
        }
    }
}

extension MainABI {
    // 字节数组，e.g. goods1[0] + goods2[0] = data，data => 哈希地址
    
    // 查询商家的全部商品[Account合约]
    // function getGoods (address sellerAddress) public view returns (bytes32[] goods1, bytes14[] goods2)
    public func getGoods(sellerAddress: String, complete:(([String]?, Error?) -> Void)?) {
        self.readInfo(method: "getGoods", parameters: [sellerAddress as AnyObject]) { (keyValues, error) in
            var res = [String]()
            if let kv = keyValues {
                if let goods1: [Data] = kv["goods1"] as? [Data], let goods2: [Data] = kv["goods2"] as? [Data] {
                    if !goods1.isEmpty && !goods2.isEmpty && goods1.count == goods2.count {
                        for i in 0 ..< goods1.count {
                            let s1: String = String.init(data: goods1[i], encoding: .utf8)!
                            let s2: String = String.init(data: goods2[i], encoding: .utf8)!
                            res.append(s1+s2)
                        }
                    }
                }
            }
            complete?(res.isEmpty ? nil : res, error)
        }
    }
    
    // 根据标签获取首页全部商品信息
    // function getIndexGoods (string index) public view returns (bytes32[] goods1, bytes14[] goods2)
    public func getIndexGoods(index: String = "成都", complete:(([String]?, Error?) -> Void)?) {
        self.readInfo(method: "getIndexGoods", parameters: [index as AnyObject]) { (keyValues, error) in
            var res = [String]()
            if let kv = keyValues {
                if let goods1: [Data] = kv["goods1"] as? [Data], let goods2: [Data] = kv["goods2"] as? [Data] {
                    if !goods1.isEmpty && !goods2.isEmpty && goods1.count == goods2.count {
                        for i in 0 ..< goods1.count {
                            let s1: String = String.init(data: goods1[i], encoding: .utf8)!
                            let s2: String = String.init(data: goods2[i], encoding: .utf8)!
                            res.append(s1+s2)
                        }
                    }
                }
            }
            complete?(res.isEmpty ? nil : res, error)
        }
    }
}

extension MainABI {
    // 获取商品number
    // function getNumber(string ipfsHash) public view returns (uint256[2]) { return account.getNumber(msg.sender, ipfsHash); }
    // "0x02CA844F54f0cF4e36eF6214894Ae58fE6560076"
    // "QmYmNfoifE34ycx88RB7WUdQcB6dz6A4qyA96UoQYxcdBt"
    public func getNumber(goodsIpfsHash: String, complete:(([_BigUInt]?, Error?) -> Void)?) {
        var options: TransactionOptions = TransactionOptions.init()
        options.from = KeyManager.instance.ethereumAddress
        self.readInfo(method: "getNumber", parameters: [goodsIpfsHash as AnyObject], options: options) { (keyValues, error) in
            let res: [_BigUInt]? = (keyValues?.values.first) as? [_BigUInt]
            complete?(res,error)
        }
    }
}
