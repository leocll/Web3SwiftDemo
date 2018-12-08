//
//  HouseInfoViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/12.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation

class HouseInfoViewModel {
    
    enum ByWho {
        case add
        case edit(HouseModel)
    }
    struct Business {
        var action: ((HouseModel)->Void)?
        var title: String
        init(_ title: String, action: ((HouseModel)->Void)? ) {
            self.title = title
            self.action = action
        }
    }
    let byWho: ByWho
    var title: String
    var house: HouseModel?
    let business: Business
    
    init(byWho: ByWho = .add) {
        self.byWho = byWho
        switch byWho {
        case .add:
            self.title = "添加房源"
            self.business = Business.init("添加", action: nil)
        case .edit(let house):
            self.title = "编辑房源"
            self.house = house
            self.business = Business.init("编辑", action: nil)
        }
    }
    
    func add(image: UIImage, house: HouseModel, complete: @escaping (Bool, Error?)->Void) {
        PPS_ipfs.addImage(image) { (hash, error) in
            guard let hs = hash, !hs.isEmpty else {
                complete(false, NSError.init(domain: "上传图片失败", code: 0, userInfo: nil))
                return
            }
            house.imageUrl = hs
            let json: [String: Any] = house.toJSON()
            print(json)
            PPS_ipfs.addDict(json, complete: { (hash, error) in
                guard let hs = hash, !hs.isEmpty else {
                    complete(false, NSError.init(domain: "上传房源失败", code: 0, userInfo: nil))
                    return
                }
                MainABI.instance.write(.addGoods(index: house.city!, ipfsHash: hs, price: String(house.price)), complete: { (tx, error) in
                    guard let tx = tx, !tx.isEmpty, error == nil else {
                        complete(false, NSError.init(domain: "添加失败", code: 0, userInfo: nil))
                        return
                    }
                    MeController.refresh()
                    complete(true, nil)
                })
            })
        }
    }
    
    func edit(image: UIImage?, house: HouseModel, complete: @escaping (Bool, Error?)->Void) {
        MainABI.instance.getNumber(goodsIpfsHash: self.house!.ipfsHash_source!) { (bigUInts, error) in
            guard let bInts = bigUInts, bInts.count == 2 else {
                complete(false, NSError.init(domain: "修改失败", code: 0, userInfo: nil))
                return
            }
            
            let block: (String?)->Void = { (hash) in
                if let hs = hash { house.imageUrl = hs }
                let json: [String: Any] = house.toJSON()
                print(json)
                PPS_ipfs.addDict(json, complete: { (hash, error) in
                    guard let hs = hash, !hs.isEmpty else {
                        complete(false, NSError.init(domain: "上传新房源失败", code: 0, userInfo: nil))
                        return
                    }
                    MainABI.instance.write(.changeGoods(userNum: bInts[0], homeNum: bInts[1], oldHash: self.house!.ipfsHash_source!, newHash: hs, index: house.city!, price: String(house.price)), complete: { (tx, error) in
                        guard let tx = tx, !tx.isEmpty, error == nil else {
                            complete(false, NSError.init(domain: "修改失败", code: 0, userInfo: nil))
                            return
                        }
                        HouseDetailController.refresh(ipfsHash: hs)
                        HouseListController.refresh()
                        complete(true, nil)
                    })
                })
            }
            
            if let img = image {
                PPS_ipfs.addImage(img) { (hash, error) in
                    guard let hs = hash, !hs.isEmpty else {
                        complete(false, NSError.init(domain: "上传新图片失败", code: 0, userInfo: nil))
                        return
                    }
                    block(hs)
                }
            } else {
                block(nil)
            }
        }
    }
    
}
