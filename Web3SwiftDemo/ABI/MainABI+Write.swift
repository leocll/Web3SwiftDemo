//
//  MainABI+TrustWallet.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/6.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation
import BigInt
import Result
import Web3swift
import EthereumAddress

extension MainABI {
    enum Write {
        case register(ipfsHash: String)
        case changeInfo(ipfsHash: String)
        case addGoods(index: String, ipfsHash: String, price: String)
        case changeGoods(userNum: _BigUInt, homeNum: _BigUInt, oldHash: String, newHash: String, index: String, price: String)
        case newOrder(sellerAddress: String, ipfsHash: String, startTime: String, price: String)
        case orderDone(orderAddress: String, endTime: String)
        case refundApply(orderAddress: String)
        case refundAgree(orderAddress: String, endTime: String)

        var method: String {
            switch self {
            case .register: return "register"
            case .changeInfo: return "changeInfo"
            case .addGoods: return "addGoods"
            case .changeGoods: return "changeGoods"
            case .newOrder: return "newOrder"
            case .orderDone: return "orderDone"
            case .refundApply: return "refundApply"
            case .refundAgree: return "refundAgree"
            }
        }
        var parameters: [AnyObject] {
            var para: [Any] = [Any]()
            switch self {
            case .register(let ipfsHash):
                para = [ipfsHash]
            case .changeInfo(let ipfsHash):
                para = [ipfsHash]
            case .addGoods(let index, let ipfsHash, let price):
                // 上传字符串
//                let ether: BigUInt = Web3.Utils.parseToBigUInt(price, units: .eth) ?? BigUInt(Int(price) ?? 0)
                if let data = ipfsHash.data(using: .utf8), data.count == 46 {
                    para = [index, ipfsHash, data.subdata(in: 0 ..< 32), data.subdata(in: 32 ..< 46), price]
                } else {
                    para = [index, ipfsHash, price]
                }
            case .changeGoods(let userNum, let homeNum, let oldHash, let newHash, let index, let price):
                if let data = newHash.data(using: .utf8), data.count == 46 {
                    para = [userNum, homeNum, oldHash, newHash, data.subdata(in: 0 ..< 32), data.subdata(in: 32 ..< 46), index, price]
                } else {
                    para = [userNum, homeNum, oldHash, newHash, index, price]
                }
            case .newOrder(let sellerAddress, let ipfsHash, let startTime, _):
                para = [sellerAddress, ipfsHash, startTime]
            case .orderDone(let orderAddress, let endTime):
                para = [orderAddress, endTime]
            case .refundApply(let orderAddress):
                para = [orderAddress]
            case .refundAgree(let orderAddress, let endTime):
                para = [orderAddress, endTime]
            }
            return para as [AnyObject]
        }
        var options: TransactionOptions {
            var options: TransactionOptions = TransactionOptions()
            options.from = KeyManager.instance.ethereumAddress!
            options.gasLimit = TransactionOptions.GasLimitPolicy.manual(_BigUInt(5000000))
            switch self {
            case .register: return options
            case .changeInfo: return options
            case .addGoods: return options
            case .changeGoods: return options
            case .newOrder(_, _, _, let price):
                let ether = Web3.Utils.parseToBigUInt(price, units: .eth)
                options.value = ether
                return options
            case .orderDone: return options
            case .refundApply: return options
            case .refundAgree: return options
            }
        }
    }
    
    public func write(_ wr: Write, complete:((String?, Error?)->Void)?) {
        self.writeInfo(method: wr.method, parameters: wr.parameters, options: wr.options) { (res, error) in
            complete?(res?.hash, error)
        }
    }
    
    private func writeInfo(method: String, parameters: [AnyObject] = [AnyObject](), options: TransactionOptions? = nil, data: Data = Data(), complete:((TransactionSendingResult?, Error?)->Void)?) {
        DispatchQueue.global().async {
            do {
                let value: TransactionSendingResult? = try self.contract.method(method, parameters: parameters, extraData: data, transactionOptions: options)?.send(password: KeyManager.instance.password, transactionOptions: options)
                if value != nil {
                    print("hash:\(value!.hash)\n\(value!.transaction.description)")
                }
                DispatchQueue.main.async { complete?(value,nil) }
            } catch {
                DispatchQueue.main.async { complete?(nil,error) }
                print(error)
            }
        }
    }
    
    //注册账户 [将用户信息存储在IPFS上，这里只保存ipfs的哈希值]
//    function register(string ipfsHash) public {
//    account.register(msg.sender, ipfsHash);
//    emit RegisterEvent(msg.sender, ipfsHash);
//    }
    
    //更新账户信息
//    function changeInfo(string ipfsHash) public {
//    account.changeInfo(msg.sender, ipfsHash);
//    emit ChangeInfoEvent(msg.sender, ipfsHash);
//    }
    
    //上传商品信息
//    function addGoods(string index, string ipfsHash, bytes32 ipfsHash1, bytes14 ipfsHash2, uint256 price) public {
//    uint256 homeNum = store.addGoods(index, ipfsHash, ipfsHash1, ipfsHash2, price);
//    uint256 userNum = account.addGoods(msg.sender, ipfsHash, ipfsHash1, ipfsHash2, homeNum);
//    emit AddGoodsEvent(msg.sender, index, ipfsHash, userNum, homeNum, price);
//    }
    
    //更改商品信息(目前只支持单一标签，比如城市)
//    function changeGoods(uint256 userNum, uint256 homeNum, string oldHash, string newHash,
//    bytes32 ipfsHash1, bytes14 ipfsHash2, string index, uint256 price
//    ) public {
//    account.changeGoods(msg.sender, userNum, homeNum, oldHash, newHash, ipfsHash1, ipfsHash2);
//    store.changeGoods(index, homeNum, oldHash, newHash, ipfsHash1, ipfsHash2, price);
//    emit ChangeGoodsEvent(msg.sender, index, userNum, homeNum, oldHash, newHash, price);
//    }
    
    //买家下单（买家发起）
//    function newOrder(address seller, string ipfsHash, string startTime) public payable {
//    //部署新合约，合约应该与买家和卖家联系起来，可以通过买家或者卖家的地址找到这个订单合约的地址
//    //可以存储在Stroge合约中
//    //在部署合约的时候，直接将参数传进订单合约中（买方，卖方，房子id，金额，规则等）
//    require(account.verifySeller(seller, ipfsHash), "seller don`t have this goods");
//    uint256 price = store.getPrice(ipfsHash);
//    require(msg.value == price * 1e18, "pay wrong value!");
//    Order orderInstance = new Order(seller, msg.sender, ipfsHash, price, startTime);
//    account.addOrder(msg.sender, seller, address(orderInstance));
//    address(orderInstance).transfer(msg.value);
//    emit NewOrderEvent(msg.sender, seller, orderInstance, ipfsHash, price);
//    }
    
    //订单完成（买家发起，还需要其他方式，比如时间）
//    function orderDone(address orderAddress, string endTime) public {
//    Order orderInstance = Order(orderAddress);
//    orderInstance.orderDone(msg.sender, endTime);
//    emit OrderDoneEvent(msg.sender, orderAddress);
//    }
    
    //买家申请退款（买家发起）
//    function refundApply(address orderAddress) public {
//    Order orderInstance = Order(orderAddress);
//    orderInstance.refundApply(msg.sender);
//    emit RefundEvent(msg.sender, orderAddress);
//    }
    
    //卖家同意退款（卖家发起，还需要其他监督方式）
//    function refundAgree(address orderAddress, string endTime) public {
//    Order orderInstance = Order(orderAddress);
//    orderInstance.refundAgree(msg.sender, endTime);
//    emit RefundAgreeEvent(msg.sender, orderAddress);
//    }
}
