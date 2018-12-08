//
//  KeyManager.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/8.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation
import KeychainSwift
import Web3swift
import EthereumAddress

class KeyManager {
    enum NotiName: String {
        case keystoreManagerChanged
    }
    static var hasKey: Bool {
        return KeyManager.instance.address != nil ? !(KeyManager.instance.address!.isEmpty) : false
    }
    
    private let keystoreManagerPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/keystore")
    private let keystoreJsonPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/keystore/keystore.json")
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    private let keychain: KeychainSwift
    var keystoreManager: KeystoreManager? {
        didSet {
            self._ethereumAddress = self.keystoreManager?.addresses?.first
            self._address = self.ethereumAddress?.address
        }
    }
    private var _address: String?
    var address: String? { return self._address }
    private var _ethereumAddress: EthereumAddress?
    var ethereumAddress: EthereumAddress? { return self._ethereumAddress }
    
    var password: String {
        return self.keychain.get(self.address!)!//"web3swift"
    }
    
    public static let instance: KeyManager = KeyManager.init()
    private init() {
        self.keychain = KeychainSwift.init(keyPrefix: "leocll")
        self.keychain.synchronizable = false
        self.keystoreManager = KeystoreManager.managerForPath(self.keystoreManagerPath)
        self._ethereumAddress = self.keystoreManager?.addresses?.first
        self._address = self.ethereumAddress?.address
    }
    
    func importPrivateKey(_ key: String, passwd: String, complete: ((Bool, Error?)->Void)?) {
        let newPassword = passwd//PasswordGenerator.generateRandom()
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            complete?(false, AbstractKeystoreError.invalidPasswordError)
            return
        }
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: newPassword) else {
            complete?(false, AbstractKeystoreError.invalidPasswordError)
            return
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            complete?(false, AbstractKeystoreError.invalidPasswordError)
            return
        }
        guard let keyData = try? wallet.serialize() else {
            complete?(false, AbstractKeystoreError.invalidPasswordError)
            return
        }
        guard let address: String = newWallet?.addresses?.first?.address else {
            complete?(false, AbstractKeystoreError.invalidPasswordError)
            return
        }
        // 写入本地
        try? FileManager.default.removeItem(atPath: self.keystoreJsonPath)
        FileManager.default.createFile(atPath: self.keystoreJsonPath, contents: keyData, attributes: nil)
        // 存入内存
        KeystoreManager.allManagers.removeAll()
        KeystoreManager.allManagers.append(KeystoreManager.managerForPath(self.keystoreManagerPath)!)
        self.keystoreManager = KeystoreManager.defaultManager
        // 保存密码
        self.keychain.set(newPassword, forKey: address, withAccess: self.defaultKeychainAccess)

        complete?(true, nil)
    }
    
    func keystoreManagerChanged() {
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: NotiName.keystoreManagerChanged.rawValue), object: nil)
    }
    
    static func clear() {
        KeyManager.instance.keystoreManager = nil
        KeystoreManager.allManagers.removeAll()
        try? FileManager.default.removeItem(atPath: KeyManager.instance.keystoreJsonPath)
    }
}
