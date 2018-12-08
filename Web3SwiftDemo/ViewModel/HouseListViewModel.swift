//
//  ListViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/1.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit

class HouseListViewModel {
    
    typealias Request = ([HouseModel]?,Error?) -> Void
    
    enum ByWho {
        case index(String)
        case user(String?)
        case hashes([String])
        
        var request: ((Request?) -> Void) {
            switch self {
            case .index(let index):
                let request: ((Request?) -> Void) = { (block) in
                    HouseModel.getHousesByIndex(index, complete: block)
                }
                return request
            case .user(let address):
                let request: ((Request?) -> Void) = { (block) in
                    HouseModel.getHousesByUser(address, complete: block)
                }
                return request
            case .hashes(let hhs):
                return { (block: Request?) -> Void in
                    HouseModel.getHouses(hhs, complete: block)
                }
            }
        }
        var rightBusiness: Business? {
            switch self {
            case .index: return nil
            default:
                return Business.init(.add, action: { (_) in
                    guard let _ = KeyManager.instance.address else {
                        let vc: LoginController = LoginController.init()
                        Screen.currentController.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                    let vc: HouseInfoController = HouseInfoController.init()
                    Screen.currentController.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
        var rowBusiness: Business {
            switch self {
            case .index:
                return Business.init(.row, action: { (house) in
                    let vc: HouseDetailController = HouseDetailController.init()
                    vc.viewModel = HouseDetailViewModel.init(byWho: .index(house!))
                    Screen.currentController.navigationController?.pushViewController(vc, animated: true)
                })
            default:
                return Business.init(.row, action: { (house) in
                    let vc: HouseDetailController = HouseDetailController.init()
                    vc.viewModel = HouseDetailViewModel.init(byWho: .user(house!))
                    Screen.currentController.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
    struct Business {
        enum `Type`: String {
            case add = "添加"
            case row = ""
        }
        let type: Type
        let action: (HouseModel?)->Void
        var title: String { return self.type.rawValue }
        
        init(_ type: Type, action: @escaping (HouseModel?)->Void ) {
            self.type = type
            self.action = action
        }
    }
    var title: String = "热门房源"
    let rightBusiness: Business?
    let rowBusiness: Business

    private var request: ((Request?) -> Void)
    
    init(byWho:ByWho = .index("成都")) {
        // test
        self.request = byWho.request// ByWho.user(nil).request
        self.rightBusiness = byWho.rightBusiness
        self.rowBusiness = byWho.rowBusiness
    }
    
    public func getHouses(complete:(([HouseModel]?,Error?) -> Void)?) {
        self.request(complete)
    }
}
