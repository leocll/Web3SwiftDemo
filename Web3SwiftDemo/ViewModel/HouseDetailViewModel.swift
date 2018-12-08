//
//  HouseDetailViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/12.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation

class HouseDetailViewModel {

    enum ByWho {
        case index(HouseModel)
        case user(HouseModel)
    }
    struct Business {
        enum `Type`: String {
            case edit = "编辑"
            case buy = "购买"
        }
        let type: Type
        var action: ((HouseModel)->Void)?
        var title: String { return self.type.rawValue }

        init(_ type: Type, action: ((HouseModel)->Void)? ) {
            self.type = type
            self.action = action
        }
    }
    var title: String = "房源详情"
    var house: HouseModel
    let rightBusiness: Business?
    let bottomBusiness: Business?
    
    init(byWho: ByWho) {
        switch byWho {
        case .index(let house):
            self.house = house
            self.rightBusiness = nil
            self.bottomBusiness = Business.init(.buy, action: nil)
        case .user(let house):
            self.house = house
            self.rightBusiness = Business.init(.edit, action: { (house) in
                let vc: HouseInfoController = HouseInfoController.init()
                vc.viewModel = HouseInfoViewModel.init(byWho: .edit(house))
                Screen.currentController.navigationController?.pushViewController(vc, animated: true)
            })
            self.bottomBusiness = nil
        }
    }
    
    public func update(ipfsHash: String, complete:((HouseModel?, Error?)->Void)?) {
        HouseModel.getHouses([ipfsHash]) { (houses, error) in
            if let house = houses?.first { self.house = house }
            complete?(houses?.first, error)
        }
    }
    
    public func buy(complete: @escaping ((Bool, Error?)->Void)) {
        guard let address = KeyManager.instance.address else {
            complete(false, NSError.init(domain: "请先登录", code: 100, userInfo: nil))
            let vc: LoginController = LoginController.init()
            Screen.currentController.navigationController?.pushViewController(vc, animated: true)
            return
        }
//        guard address == self.house!.seller  else {
//            complete(false, NSError.init(domain: "不能购买自己的房源", code: 100, userInfo: nil))
//            return
//        }
        let time: String = String(Date().timeIntervalSince1970 * 1000)
        MainABI.instance.write(.newOrder(sellerAddress: address, ipfsHash: self.house.ipfsHash_source!, startTime: time, price:String(self.house.price))) { (tx, error) in
            guard let tx = tx, !tx.isEmpty, error == nil else {
                complete(false, NSError.init(domain: "购买失败", code: 0, userInfo: nil))
                return
            }
            MeController.refresh()
            complete(true, nil)
        }
    }
}
