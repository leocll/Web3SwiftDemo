//
//  OrderListViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/2.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit

class OrderListViewModel {
    typealias Request = ([OrderModel]?,Error?) -> Void
    
    enum ByWho {
        case abiOrders([MainABI.MainABI_OrderInfo])
    }
    
    let byWho: ByWho
    var title: String = "订单列表"
    
    private var request: (((Request)?) -> Void)?
    
    init(byWho:ByWho) {
        self.byWho = byWho
    }
    
    private static func createRequest(byWho: ByWho) -> ((Request?) -> Void) {
        switch byWho {
        case .abiOrders(let abiOrders):
            let request: ((Request?) -> Void) = { (block) in
                OrderModel.getOrders(byAbiOrders: abiOrders, complete: block)
            }
            return request
        }
    }
    
    public func getOrders(complete:(([OrderModel]?,Error?) -> Void)?) {
        if self.request == nil {
            self.request = OrderListViewModel.createRequest(byWho: self.byWho)
        }
        self.request?(complete)
    }
}
