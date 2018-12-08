//
//  ModifyUserInfoController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/9.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLHud
import CLLBasic

class ModifyUserInfoController: CLLBaseViewController, UITextFieldDelegate {

    private var tf: UITextField!
    private var btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "修改信息"
        self.view.backgroundColor = UIColor.white
        
        self.tf = UITextField.init()
        self.tf.font = UIFont.normal
        self.tf.textColor = UIColor.normalText
        self.tf.textAlignment = .center
        self.tf.placeholder = "请输入新昵称"
        self.tf.borderStyle = .roundedRect
        self.tf.delegate = self
        self.tf.size = CGSize.init(width: 200, height: 30)
        self.tf.centerX = self.view.width * 0.5
        self.tf.centerY = self.view.height * 0.5 - 150
        self.view.addSubview(self.tf)

        self.btn = CLLViewTool.makeButton({ (btn) in
            btn.titleLabel?.font = UIFont.bigger
            btn.setTitle("修改", for: .normal)
            btn.setTitleColor(UIColor.normalText, for: .normal)
            btn.size = CGSize.init(width: 80, height: 30)
            btn.centerX = self.view.width * 0.5
            btn.top = self.tf.bottom + 100
            btn.textShadow()
            btn.addTarget(self, action: #selector(self.touchesButton), for: .touchUpInside)
            self.view.addSubview(btn)
        })
    }
    
    @objc func touchesButton() {
        guard let text = self.tf.text, !text.isEmpty else {
            CLLHud.showTipMessage("请输入新昵称")
            return
        }
        UIAlertController.passwordVerifyAlert {
            self.modify()
        }
    }
    
    private func modify() {
        CLLHud.showLoading(to: self.view, animated: true)
        PPS_ipfs.addDict(["nickName": self.tf.text!]) { (hash, error) in
            guard let hs = hash, !hs.isEmpty else {
                CLLHud.hide(for: self.view)
                CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "修改失败")
                return
            }
            MainABI.instance.write(.changeInfo(ipfsHash: hs), complete: { (tx, error) in
                CLLHud.hide(for: self.view)
                guard let tx = tx, !tx.isEmpty, error == nil else {
                    CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "修改失败")
                    return
                }
                MeController.refresh()
                CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "修改成功")
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
