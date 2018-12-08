//
//  CustomAbi.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/30.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import BigInt

typealias _BigUInt = BigUInt

struct CustomABI {
    enum ABIName {
        case main
    }
    let abiName: ABIName
    let address: String
    let abi: String
    
    init(abiName name: ABIName = .main) {
        self.abiName = name
        switch name {
        case .main:
            self.address = "0xace753d27a7c73253c6c05e7b1c3716171f02745"
            
            let main: String = try! String.init(contentsOfFile: Bundle.main.path(forResource: "Main", ofType: "json")!)
            let dict = try! JSONSerialization.jsonObject(with: main.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
            let abiDict = dict["abi"]
            let data = try? JSONSerialization.data(withJSONObject: abiDict!, options: [])
            self.abi = String(data: data!, encoding: String.Encoding.utf8)!
        }
    }
}

struct KeyStoreConfig {
    let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//    let keyStorePath: String = 
}
