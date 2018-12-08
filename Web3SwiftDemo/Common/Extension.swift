//
//  Extension.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/6.
//  Copyright © 2018年 admin. All rights reserved.
//

import Foundation
import CLLHud

extension Dictionary {
    public var jsonData: Data? {
        if !JSONSerialization.isValidJSONObject(self) {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
}

extension Array {
    public var jsonData: Data? {
        if !JSONSerialization.isValidJSONObject(self) {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
}

extension JSONDecoder {
    public static func decode<T>(_ type: T.Type, fromDict dict: [String: Any]) throws -> T where T : Codable {
        guard let data = dict.jsonData else {
            throw NSError.init(domain: "dict -> data to error", code: 0, userInfo: nil)
        }
        guard let model = try? JSONDecoder().decode(type, from: data) else {
            throw NSError.init(domain: "data -> model to error", code: 0, userInfo: nil)
        }
        return model
    }
}

extension UILabel {
    public func textShadow(color: UIColor = UIColor.normalText, text: Bool = true) {
        self.textColor = color
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        self.layer.shadowOpacity = 1
    }
}

extension UIButton {
    public func textShadow(color: UIColor = UIColor.touchColor, text: Bool = true) {
        self.setTitleColor(color, for: .normal)
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        self.layer.shadowOpacity = 1
    }
}

extension UIAlertController {
    static func showInputPasswordAlert(_ handle: ((String)->Void)?) {
        let alert = UIAlertController.init(title: "输入钱包密码", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.font = UIFont.normal
            tf.textColor = UIColor.normalText
            tf.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { [weak alert] (action) in
            if let passwd = alert?.textFields?.first?.text {
                handle?(passwd)
            }
        }))
        Screen.currentController.present(alert, animated: true, completion: nil)
    }
    
    static func passwordVerifyAlert(_ pass:@escaping (()->Void)) {
        UIAlertController.showInputPasswordAlert { (passwd) in
            guard !passwd.isEmpty, !KeyManager.instance.password.isEmpty, passwd == KeyManager.instance.password else {
                CLLHud.showTipMessage("密码错误")
                return
            }
            pass()
        }
    }
}
