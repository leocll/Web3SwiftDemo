//
//  MathWalletOperation.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/5.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
//import web3swift
import CryptoSwift
import BigInt

class MathWalletTest {
    
    public static func login() {
        let loginReq: MathWalletLoginReq = MathWalletLoginReq.init()
        // eosio、eosforce、ethereum
        loginReq.blockchain = "ethereum"
        loginReq.dappIcon = "http://www.mathwallet.org/images/download/wallet_cn.png"
        loginReq.dappName = "LiananTechHouse"
        loginReq.uuID = "123456"
        // 若有服务器的情况下，服务器将其uuid的用户置于已登录的状态，用于后续业务逻辑处理
        loginReq.loginUrl = "http://op.juhe.cn/onebox/movie/video?dtype=&q=dier&key=a0fae95083c57d3701829878c5269032"
        loginReq.expired = NSNumber.init(value: NSDate.init().timeIntervalSince1970 + 60)
        // 备注
        loginReq.loginMemo = "test备注"
        MathWalletAPI.send(loginReq)
    }
    
    public static func register(_ address: String = "0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC") {
        let transferReq: MathWalletTransferReq = MathWalletTransferReq.init()
        // 公链标识
        transferReq.blockchain = "ethereum"  // eosio、eosforce、ethereum
        // DApp信息
        transferReq.dappIcon = "http://www.mathwallet.org/images/download/wallet_cn.png"
        transferReq.dappName = "LiananTechHouse";
        // 转账信息
//        transferReq.from = address//"0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC";//test//@"eosioaccount";
        transferReq.to = "0x4c4E30d8Edd69829B2659e30cF8aA5818EA8a3b8";//leocll@"eosioaccount";
//        transferReq.to = MainABI.instance.address
        transferReq.amount = "1"
        transferReq.precision = (18)
        transferReq.symbol = "ETH"//@"EOS";

        var dda: Date? = nil//MainABI.instance.funcData(method: "register", parameters: ["QmdQeBGRZg2SwfJyAs1Vv5iwZHAr1qdWVRANPChATg6eaH" as AnyObject])
//        let hex4 = dda?.toHexString()
        var data: Data = "register".data(using: .utf8)! + "QmdQeBGRZg2SwfJyAs1Vv5iwZHAr1qdWVRANPChATg6eaH".data(using: .utf8)!
        let hex1 = data.toHexString()
        let hex2 = "registerQmdQeBGRZg2SwfJyAs1Vv5iwZHAr1qdWVRANPChATg6eaH".data(using: .utf8)!.toHexString()
        let hex3 = ["MethodID":"register",]
        let hex = ["register","QmdQeBGRZg2SwfJyAs1Vv5iwZHAr1qdWVRANPChATg6eaH"].jsonData!.toHexString()
        transferReq.dappData = hex//转账的附属信息，将同步到去中心化服务器

        transferReq.desc = "test desc";//用于UI展示
        transferReq.expired = NSNumber.init(value: NSDate.init().timeIntervalSince1970 + 60)

        MathWalletAPI.send(transferReq)
    }
    
//    public static func register(_ address: String = "0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC") {
//        let transferReq: MathWalletTransactionReq = MathWalletTransactionReq.init()
//        // 公链标识
//        transferReq.blockchain = "ethereum"  // eosio、eosforce、ethereum
//        // DApp信息
//        transferReq.dappIcon = "http://www.mathwallet.org/images/download/wallet_cn.png"
//        transferReq.dappName = "LiananTechHouse";
//        // 转账信息
//        transferReq.from = address//"0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC";//test//@"eosioaccount";
//
//        let hex = "QmdQeBGRZg2SwfJyAs1Vv5iwZHAr1qdWVRANPChATg6eaH".data(using: .utf8)?.toHexString()
//        transferReq.dappData = "Function='register'&ipfsHash='\(hex!)'"//转账的附属信息，将同步到去中心化服务器
//
//        transferReq.desc = "描述";//用于UI展示
//        transferReq.expired = NSNumber.init(value: NSDate.init().timeIntervalSince1970 + 60)
//
//        MathWalletAPI.send(transferReq)
//    }
}
