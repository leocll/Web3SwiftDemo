//
//  MainContractABI.swift
//  Web3SwiftDemo
//
//  Created by leocll on 2018/10/27.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import EthereumAddress

final class MainABI {
    
    private static let abi: CustomABI = CustomABI(abiName: .main)
    let contract: web3.web3contract
    let web3Instance: web3
    
    public var address: String {
        return MainABI.abi.address
    }
    
    public static let instance: MainABI = MainABI.init()
    
    private init(netWork: Networks = .Rinkeby) {
        self.web3Instance = web3.init(provider: Web3HttpProvider.init(URL.init(string: "https://rinkeby.infura.io/v3/490173507b2a4d4ea5ae8762e0882c6e"/*"http://45.62.114.149:8545"*/)!, network: .Rinkeby, keystoreManager: nil)!)
        self.contract = self.web3Instance.contract(MainABI.abi.abi, at: EthereumAddress(MainABI.abi.address), abiVersion: 2)!
        self.web3Instance.addKeystoreManager(KeyManager.instance.keystoreManager)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: KeyManager.NotiName.keystoreManagerChanged.rawValue), object: nil, queue: nil) { [weak self] (_) in
            self?.web3Instance.addKeystoreManager(KeyManager.instance.keystoreManager)
        }
    }
    
    private static let form: EthereumAddress = EthereumAddress("0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC")!
}


extension MainABI {
    // 注册账户 [将用户信息存储在IPFS上，这里只保存ipfs的哈希值]
    // function register(string ipfsHash) public {
    // account.register(msg.sender, ipfsHash);
    // emit RegisterEvent(msg.sender, ipfsHash);
    // }
}

extension MainABI {
    // 更新账户信息
    // function changeInfo(string ipfsHash) public {
    // account.changeInfo(msg.sender, ipfsHash);
    // emit ChangeInfoEvent(msg.sender, ipfsHash);
    // }
}

/************** 查询 **************/

