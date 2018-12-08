//
//  MeViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/2.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud

class MeViewModel {
    class MeItem {
        enum Item: String {
            case nickName = "昵称"                 // 昵称
            case adress = "地址"                   // 钱包地址
            case orderingRecord = "未完成的订单"    // 未完成的订单
            case orderedRecord = "已完成的订单"     // 已完成的订单
            case goodsList = "商品列表"            // 商品列表
            case toDoOrder = "待处理的订单"         // 待处理的订单
            case clean = "清除缓存"                // 清除缓存
            case login = "去登录"
            
            var icon: UIImage {
                switch self {
                case .nickName: return UIImage.init(named: "nickName")!
                case .adress: return UIImage.init(named: "adress")!
                case .orderingRecord: return UIImage.init(named: "orderingRecord")!
                case .orderedRecord: return UIImage.init(named: "orderedRecord")!
                case .goodsList: return UIImage.init(named: "goodsList")!
                case .toDoOrder: return UIImage.init(named: "toDoOrder")!
                case .clean: return UIImage.init(named: "clean")!
                case .login: return KeyManager.hasKey ? UIImage.init(named: "logout")! : UIImage.init(named: "login")!
                }
            }
            var title: String {
                switch self {
                case .login: return KeyManager.hasKey ? "退出登录" : self.rawValue
                default: return self.rawValue
                }
            }
            var logoutArrow: Bool {
                switch self {
                case .login: return true
                default: return false
                }
            }
        }
        let item: Item
        var action: ((MeItem, MeViewModel) -> Void)?
        fileprivate var _desc: String?
        var desc: String? { return KeyManager.hasKey ? _desc : nil }
        fileprivate var _arrow: Bool
        var arrow: Bool { return KeyManager.hasKey ? _arrow : item.logoutArrow }
        
        init(item: Item, arrow: Bool = false, action: ((MeItem, MeViewModel) -> Void)?) {
            self.item = item
            self.action = action
            self._arrow = arrow
        }
    }
    
    var title: String = "我的"
    let items: [[MeItem]] = { () -> [[MeItem]] in
        var itemArry: [[MeItem]] = [[MeItem]]()
        itemArry += [[MeItem(item: .nickName, arrow: true, action: { (item, _) in
            if !item.arrow { return }
            let vc: ModifyUserInfoController = ModifyUserInfoController.init()
            Screen.currentController.navigationController?.pushViewController(vc, animated: true)
        }),MeItem(item: .adress, action: { (_, _) in
            
        })]]
        itemArry += [[MeItem(item: .orderingRecord, action: { (item, vm) in
            if !item.arrow { return }
            let vc: OrderListController = OrderListController.init()
            vc.viewModel = OrderListViewModel.init(byWho: .abiOrders(vm.doingOrder))
            vc.viewModel.title = item.item.title
            Screen.currentController.navigationController?.pushViewController(vc, animated: true)
        }),MeItem(item: .orderedRecord, action: { (item, vm) in
            if !item.arrow { return }
            let vc: OrderListController = OrderListController.init()
            vc.viewModel = OrderListViewModel.init(byWho: .abiOrders(vm.doneOrder))
            vc.viewModel.title = item.item.title
            Screen.currentController.navigationController?.pushViewController(vc, animated: true)
        }),MeItem(item: .toDoOrder, action: { (item, vm) in
            if !item.arrow { return }
            let vc: OrderListController = OrderListController.init()
            vc.viewModel = OrderListViewModel.init(byWho: .abiOrders(vm.toDoOrder))
            vc.viewModel.title = item.item.title
            Screen.currentController.navigationController?.pushViewController(vc, animated: true)
        })]]
        itemArry += [[MeItem(item: .goodsList, action: { (item, vm) in
            if !item.arrow { return }
            if vm.goodsHashes.isEmpty {
                let vc: HouseInfoController = HouseInfoController.init()
                Screen.currentController.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc: HouseListController = HouseListController.init()
//                vc.viewModel = HouseListViewModel.init(byWho: .hashes(vm.goodsHashes))
                vc.viewModel = HouseListViewModel.init(byWho: .user(nil))
                vc.viewModel.title = item.item.title
                Screen.currentController.navigationController?.pushViewController(vc, animated: true)
            }
        })]]
        itemArry += [[MeItem(item: .clean, action: { (_, _) in
            if !KeyManager.hasKey { return }
            CLLAlertView.alert(withTitle: nil, content: "确定清除?", leftTitle: "取消", leftAction: nil, rightTitle: "确定", rightAction: { (_) in
                let view = UIApplication.shared.keyWindow
                CLLHud.showLoading(to: view, animated: true)
                DispatchQueue.global().async {
                    PPS_ipfs.clearCache()
                    DispatchQueue.main.async {
                        CLLHud.hide(for: view)
                    }
                }
            }).show()
        })]]
        itemArry += [[MeItem(item: .login, action: { (item, _) in
            if KeyManager.hasKey {
                CLLAlertView.alert(withTitle: nil, content: "确定退出?", leftTitle: "取消", leftAction: nil, rightTitle: "确定", rightAction: { (_) in
                    KeyManager.clear()
                }).show()
            } else {
                let vc: LoginController = LoginController.init()
                Screen.currentController.navigationController?.pushViewController(vc, animated: true)
            }
        })]]
        return itemArry
    }()
    
    var toDoOrder: [MainABI.MainABI_OrderInfo] = [MainABI.MainABI_OrderInfo]()
    var doingOrder: [MainABI.MainABI_OrderInfo] = [MainABI.MainABI_OrderInfo]()
    var doneOrder: [MainABI.MainABI_OrderInfo] = [MainABI.MainABI_OrderInfo]()
    var goodsHashes: [String] = [String]()

    func updateOrderes(complete: (() -> Void)?) {
        OrderModel.getAbiOrders { (abiOrders, _) in
            self.toDoOrder.removeAll()
            self.doingOrder.removeAll()
            self.doneOrder.removeAll()
            if abiOrders != nil {
                for abiOrder in abiOrders! {
                    abiOrder.status(todo: {
                        self.toDoOrder.append(abiOrder)
                    }, doing: {
                        self.doingOrder.append(abiOrder)
                    }, done: {
                        self.doneOrder.append(abiOrder)
                    })
                }
            }
            self.items[1][0]._desc = "\(self.doingOrder.count)"
            self.items[1][0]._arrow = self.doingOrder.count > 0
            self.items[1][1]._desc = "\(self.doneOrder.count)"
            self.items[1][1]._arrow = self.doneOrder.count > 0
            self.items[1][2]._desc = "\(self.toDoOrder.count)"
            self.items[1][2]._arrow = self.toDoOrder.count > 0
            complete?()
        }
    }
    func updateGoods(complete: (() -> Void)?) {
        HouseModel.getHouseHashesByUser { (hashes, _) in
            if hashes != nil {
                self.goodsHashes = hashes!
            } else {
                self.goodsHashes.removeAll()
            }
            self.items[2][0]._desc = self.goodsHashes.isEmpty ? "添加商品" : "\(self.goodsHashes.count)"
            self.items[2][0]._arrow = KeyManager.hasKey
            complete?()
        }
    }
    func updateUserInfo(complete: (() -> Void)?) {
        UserModel.getInfo { (user, nil) in
            if user == nil { return }
            self.items[0][0]._desc = user!.nickName
            self.items[0][0]._arrow = KeyManager.hasKey
            self.items[0][1]._desc = KeyManager.instance.address
            complete?()
        }
    }
}
