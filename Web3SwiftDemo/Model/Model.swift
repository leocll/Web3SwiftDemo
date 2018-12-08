//
//  Model.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import Web3swift
import ObjectMapper

class UserModel: PPS_ipfsModel, Codable {
    override func mapping(map: Map) {
        super.mapping(map: map)
        nickName <- map["nickName"]
        type <- map["type"]
    }

    var nickName: String?   // 昵称
    var type: Int = 1          // 用户类型[数值](1代表买家，2代表卖家)
    
    enum CodingKeys: String, CodingKey {
        case nickName
        case type
    }
}

class HouseModel: PPS_ipfsModel, Decodable {
    override func mapping(map: Map) {
        super.mapping(map: map)
        airConditioner <- map["airConditioner"]
        bedroom <- map["bedroom"]
        bunk <- map["bunk"]
        city <- map["city"]
        imageUrl <- map["imageUrl"]
        network <- map["network"]
        price <- map["price"]
        searchWalletType <- map["searchWalletType"]
        seller <- map["seller"]
        title <- map["title"]
        toilet <- map["toilet"]
    }

    /*{
    airConditioner: "1",
    bedroom: "1",
    bunk: "1",
    city: "chengdu",
    imageUrl: "QmV28in9a3wP896Ho789RUThro9yBKmmVG4KDKpTnuQNYo",
    network: "1",
    price: "1",
    searchWalletType: "0",
    seller: "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0",
    title: "西里的家|时光 免费寄存行李|下楼就是春熙路太古里市中心/天府广场/宽窄巷子/宜家清新风格",
    toilet: "1"
    }*/
    
    var airConditioner: Bool = false    // 空调
    var bedroom: Int = 0        // 卧室
    var bunk: Bool = false      // 跃层
    var city: String?           // 所属城市
    var imageUrl: String?        // 图片
    var network: Bool = false   // wifi
    var price: Int = 0          // 价格，单位通过后面的walletType指定
    var searchWalletType: Int = 0     // 默认使用0，即以太坊，1代表btc，2代表bch
    var seller: String?         // 卖家以太坊地址，e.g. "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0"
    var title: String?         // 标题
    var toilet: Int = 0         // 卫

    var desc: String {
        var s = ""
        if bedroom > 0 { s += "\(bedroom)室" }
        if toilet > 0 { s += "\(toilet)卫" }
        if bunk { s += "跃层" }
        if network { s += "有wifi" }
        return s
    }
    
    enum CodingKeys: String, CodingKey {
        case airConditioner
        case bedroom
        case bunk
        case city
        case imageUrl
        case network
        case price
        case searchWalletType
        case seller
        case title
        case toilet
    }
}

extension HouseModel {
    
    static func testData() -> HouseModel {
        let house: HouseModel = HouseModel.init()
        house.title = "这是一个标题"
        house.city = "这是城市"
//        house.desc = "这是一个描述"
//        house.price = "这是价格"
        return house
    }
}

class OrderModel: MainABI.MainABI_OrderInfo/*, Mappable*/ {
//    var seller: String?         // 卖家地址
//    var buyer: String?          // 买家地址
//    var ipfsHash: String?       // 商品信息的哈希地址
//    var price: Int = 0          // 商品价格
//    var startTime: String?      // 订单开始时间
//    var endTime: String?        // 订单结束时间
//    var done: Bool = false      // 订单是否已完成
//    var refund: Bool = false    // 是否申请退款
//    var agreeRefund: Bool = false   // 是否同意退款
    var house: HouseModel?      // 根据ipfsHash再次请求获得
    
//    func mapping(map: Map) {
//        seller <- map["seller"]
//        buyer <- map["seller"]
//        ipfsHash <- map["ipfsHash"]
//        price <- map["price"]
//        startTime <- map["startTime"]
//        endTime <- map["endTime"]
//        done <- map["done"]
//        refund <- map["refund"]
//        agreeRefund <- map["agreeRefund"]
//    }
    
    override var startTime: String? {
        didSet {
            transformTime()
        }
    }
    override var endTime: String? {
        didSet {
            transformTime()
        }
    }
    private var _time: String = ""
    func transformTime() {
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        var time: String = ""
        if let startTime = self.startTime, !startTime.isEmpty {
            let start = Date.init(timeIntervalSince1970: (Double(startTime)!*0.001))
            time = "开始时间：" + format.string(from: start)
        }
        if let endTime = self.endTime, !endTime.isEmpty {
            let end = Date.init(timeIntervalSince1970: (Double(endTime)!*0.001))
            time = time + (time.isEmpty ? "" : "\n") + "结束时间：" + format.string(from: end)
        }
        _time = time
    }
}

extension OrderModel {
    
    enum Action: String {
        case refund = "申请退款"        // 申请退款
        case agreeRefund = "同意退款"   // 同意退款
        case done = "完成订单"          // 完成订单
        var text: String {
            return self.rawValue
        }
    }
    
    var time: String {
        return self._time
    }
    var isSeller: Bool {
        return KeyManager.instance.address?.isEqualTo(self.seller?.address as AnyObject) ?? false
    }
    var isBuyer: Bool {
        return KeyManager.instance.address?.isEqualTo(self.buyer?.address as AnyObject) ?? false
    }
    var desc: String {
        if self.done {
            return "订单已完成"
        }
        return !self.refund ? "订单进行中" : (self.agreeRefund ? "订单已退款" : "申请退款中")
    }
    var actions: (Action?, Action)? {
        if self.done {
            return nil
        }
        if self.isSeller && self.refund && !self.agreeRefund {
            return (nil, .agreeRefund)
        }
        if self.isBuyer {
            return self.refund ? nil : (.refund, .done)
        }
        return nil
    }
    
    func status(todo:(()->Void)?, doing:(()->Void)?, done:(()->Void)?) {
        if self.done {
            done?()
        } else {
            doing?()
        }
        if self.refund && !self.agreeRefund && self.isSeller {
            todo?()
        }
    }
    
//    static func testData(_ action: Action = .none) -> OrderModel {
//        let order: OrderModel = OrderModel.init()
//        order.seller = EthereumAddress("0x00")
//        order.buyer = EthereumAddress("0x00")
//        order.ipfsHash = "fdasfasfdasfasd"
//        order.price = 0
//        order.startTime = "2018.10.29"
//        order.endTime = "2018.10.30"
//        switch action {
//        case .refund:
//            order.done = false
//            order.refund = false
//            order.agreeRefund = false
//        case .agreeRefund:
//            order.done = false
//            order.refund = true
//            order.agreeRefund = false
//        case .done:
//            order.done = true
//            order.refund = false
//            order.agreeRefund = false
//        case .none:
//            order.done = false
//            order.refund = false
//            order.agreeRefund = false
//        }
//        
//        order.house = HouseModel.testData()
//        return order
//    }
}
