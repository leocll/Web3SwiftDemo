//
//  OrderViewModel.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/7.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation

class OrderViewModel {
    var order: OrderModel
    
    init(order: OrderModel) {
        self.order = order
    }
    init(house: HouseModel) {
        self.order = OrderModel.init()
        self.order.house = house
    }
}
