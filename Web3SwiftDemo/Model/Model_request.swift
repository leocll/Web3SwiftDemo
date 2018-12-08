//
//  Model_request.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/1.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import ObjectMapper

extension UserModel {
    public static func getInfo(address: String? = KeyManager.instance.address, comlete:(((UserModel?,Error?) -> Void)?)) {
        guard let ads = address else {
            comlete?(nil, NSError.init(domain: "user address is nil", code: 100, userInfo: nil))
            return
        }
        MainABI.instance.getInfo(address: ads, complete: { (model, error) in
            guard let m = model, let hash = m.infoHash else {
                comlete?(nil,error ?? NSError.init(domain: "model.infoHash nil", code: 0, userInfo: nil))
                return
            }
            PPS_ipfs.cat(hash, complete: { (moyaResponse, error) in
                var user: UserModel? = nil
                if let data = moyaResponse?.data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    user = UserModel(JSON: json as! [String : Any])
                }
                comlete?(user, error)
            })
        })
    }
}

extension HouseModel {
    // "QmY6Q4fWfWZQhsEjNKktwCuoLLPEBfNqF1q5y546qW7KPu"
    // "QmYu5jYwsN86LUtM2HDGUXeBK8U57cdFQnERFqvQyxTm2q"
    // "QmNpQWvBbdAFhuMsHMtZitCV5gbtCxxQLkkTRLajSRF8nM"
    static let testHashs = ["QmP19fwKQASn2DCGGXfYkF7EaYNNgcRKbym1XFfLGNRc9D","QmZdxHcAE3gggArPQQnrw8WX8ne9Wgbdxuuyx5JuK4hKtQ","QmYfsuC1PLBwo2GFJYxNEBvDD1JoavsWaAXo21LTxtai8F"]
    
    public static func getHouses(_ paths: [String],complete: (([HouseModel]?,Error?) -> Void)?) {
        // mark: test
//        PPS_ipfs.catModels(paths: testHashs, type: HouseModel.self) { (models, res, error) in
//            complete?(models, error)
//        }
        
        PPS_ipfs.catModels(paths: paths, type: HouseModel.self) { (models, res, error) in
            complete?(models, error)
        }
    }
    
    public static func getHousesByIndex(_ index: String = "成都", complete: (([HouseModel]?,Error?) -> Void)?) {
        // mark: test
//        self.getHouses(testHashs, complete: complete)
        
        MainABI.instance.getIndexGoods(index: index, complete: { (hashes, error) in
            guard let hhs = hashes, !hhs.isEmpty else {
                complete?(nil, error ?? NSError.init(domain: "data is null", code: 0, userInfo: nil))
                return
            }
            self.getHouses(hhs, complete: complete)
        })
    }
    
    public static func getHousesByUser(_ address: String? = nil, complete: (([HouseModel]?,Error?) -> Void)?) {
        // mark: test
//        self.getHousesByIndex(complete: complete)
        
        var ads = address
        if ads == nil { ads = KeyManager.instance.address }
        if ads == nil {
            complete?(nil, NSError.init(domain: "user address is nil", code: 100, userInfo: nil))
            return
        }
        self.getHouseHashesByUser(address) { (hashs, error) in
            guard let hhs = hashs, !hhs.isEmpty else {
                complete?(nil, error ?? NSError.init(domain: "data is null", code: 0, userInfo: nil))
                return
            }
            self.getHouses(hhs, complete: complete)
        }
    }
    
    public static func getHouseHashesByUser(_ address: String? = nil, complete: (([String]?,Error?) -> Void)?) {
        var ads = address
        if ads == nil { ads = KeyManager.instance.address }
        if ads == nil {
            complete?(nil, NSError.init(domain: "user address is nil", code: 100, userInfo: nil))
            return
        }
        MainABI.instance.getGoods(sellerAddress: ads!, complete: { (hashes, err) in
            complete?(hashes,err)
        })
    }
}

extension OrderModel {
    
    public static func getAbiOrders(_ sellerAddress: String? = nil, complete: (([OrderModel]?,Error?) -> Void)?) {
        var ads = sellerAddress
        if ads == nil { ads = KeyManager.instance.address }
        if ads == nil {
            complete?(nil, NSError.init(domain: "user address is nil", code: 100, userInfo: nil))
            return
        }
        MainABI.instance.getOrders(sellerAddress:ads!,complete: { (ETHAddresses, e) in
            guard let ethAdses = ETHAddresses, !ethAdses.isEmpty else {
                complete?(nil, e ?? NSError.init(domain: "data is null", code: 0, userInfo: nil))
                return
            }
            var abiOrders = [OrderModel]()
            var error: Error? = nil
            
            let group = DispatchGroup.init()
            for ethAds in ethAdses {
                group.enter()
                MainABI.instance.getOrderInfo(orderAddress: ethAds.address,complete: { (abiOrder, err) in
                    if let abiO = abiOrder, let model = OrderModel(JSON: abiO.toJSON()) {
                        abiOrders.append(model)
                    }
                    error = err ?? error
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main, execute: {
                DispatchQueue.main.async {
                    complete?(abiOrders.isEmpty ? nil : abiOrders, error)
                }
            })
        })
    }
    
    public static func getOrders(byAbiOrders: [MainABI.MainABI_OrderInfo], complete: (([OrderModel]?,Error?) -> Void)?) {
        let group = DispatchGroup.init()
        
        var orders = [OrderModel]()
        var error: Error? = nil
        
        for abiOrder in byAbiOrders {
            if let ads = abiOrder.ipfsHash {
                group.enter()
                HouseModel.getHouses([ads], complete: { (houses, err) in
                    if let order = OrderModel(JSON: abiOrder.toJSON()) {
                        order.house = houses?.first
                        orders.append(order)
                    }
                    error = err ?? error
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main, execute: {
            DispatchQueue.main.async {
                complete?(orders, error)
            }
        })
    }
}
