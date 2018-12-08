//
//  LoginController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/8.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud
import Web3swift

class LoginController: CLLBaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inputPrivateKeyView: UIView!
    @IBOutlet weak var privateKeyDesc: UILabel!
    @IBOutlet weak var privateKeyTv: UITextView!
    @IBOutlet weak var privateKeyPlaceTv: UITextView!
    @IBOutlet weak var passwdTf: UITextField!
    @IBOutlet weak var passwdOnceTf: UITextField!
    @IBOutlet weak var inputNickNameView: UIView!
    @IBOutlet weak var addressDesc: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nickNameDesc: UILabel!
    @IBOutlet weak var nickNameTf: UITextField!
    var button: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "LoginController", bundle: nil)
    }
    
    convenience init() {
        self.init(nibName: "LoginController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setupUI()
        self.showInputPrivateKeyUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    private func showInputPrivateKeyUI() {
        self.inputPrivateKeyView.isHidden = false
        self.inputNickNameView.isHidden = true
        self.button.isSelected = false
    }
    
    private func showInputNikeNameUI() {
        self.addressLabel.text = KeyManager.instance.address
        self.inputPrivateKeyView.isHidden = true
        self.inputNickNameView.isHidden = false
        self.button.isSelected = true
    }
    
    private func setupUI() {
        scrollView.delegate = self

        privateKeyTv.font = UIFont.less
        privateKeyTv.delegate = self
        privateKeyTv.textContainerInset = UIEdgeInsets.init(top: 5, left: 3, bottom: 5, right: 3)
        privateKeyTv.layer.borderWidth = 0.5
        privateKeyTv.layer.borderColor = UIColor.lightLine.cgColor
        
        privateKeyPlaceTv.font = UIFont.less
        privateKeyPlaceTv.isUserInteractionEnabled = false
        privateKeyPlaceTv.textContainerInset = UIEdgeInsets.init(top: 5, left: 3, bottom: 5, right: 3)
        privateKeyPlaceTv.layer.borderWidth = 0.5
        privateKeyPlaceTv.layer.borderColor = UIColor.lightLine.cgColor
        
        passwdTf.font = UIFont.less
        passwdTf.delegate = self
        passwdTf.addTarget(self, action: #selector(textFeildDidChanged), for: .touchUpOutside)
        passwdTf.leftViewMode = .always
        passwdTf.leftView = CLLViewTool.makeVerticalLine({ (line) in
            line.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
            line.width = 5
        })
        passwdTf.layer.borderWidth = 0.5
        passwdTf.layer.borderColor = UIColor.lightLine.cgColor
        
        passwdOnceTf.font = UIFont.less
        passwdOnceTf.delegate = self
        passwdTf.addTarget(self, action: #selector(textFeildDidChanged), for: .touchUpOutside)
        passwdOnceTf.leftViewMode = .always
        passwdOnceTf.leftView = CLLViewTool.makeVerticalLine({ (line) in
            line.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
            line.width = 5
        })
        passwdOnceTf.layer.borderWidth = 0.5
        passwdOnceTf.layer.borderColor = UIColor.lightLine.cgColor
        
        let arrLabel: [UILabel] = [privateKeyDesc, addressDesc, nickNameDesc]
        for label in arrLabel {
            label.font = UIFont.normal
            label.textColor = UIColor.normalText
            label.textShadow()
        }
        nickNameTf.font = UIFont.normal
        nickNameTf.delegate = self
        
        self.button = CLLViewTool.makeButton({ (btn) in
            btn.titleLabel?.font = UIFont.bigger
            btn.setTitle("登录", for: .normal)
            btn.setTitle("完善资料", for: .selected)
            btn.setTitleColor(UIColor.normalText, for: .normal)
            btn.setTitleColor(UIColor.normalText, for: .selected)
            btn.addTarget(self, action: #selector(self.touchesButton), for: .touchUpInside)
            btn.width = Screen.width
            btn.height = 50
            btn.bottom = Device.iPhoneX ? (self.view.height - 64 - 15) : (self.view.height - 64 - 20)
            btn.textShadow()
            self.view.addSubview(btn)
        })
        self.view.addSubview(button)
    }
    
    @objc func touchesButton() {
        if self.button.isSelected {
            self.informate()
        } else {
            guard let privateKey = self.privateKeyTv.text else {
                return
            }
            guard let passwd = self.passwdTf.text, let passwdOnce = self.passwdOnceTf.text, passwd == passwdOnce else {
                CLLHud.showTipMessage("两次密码不一致")
                return
            }
            self.login()
        }
    }
    
    private func login() {
        CLLHud.showLoading(to: self.view, animated: true)
        KeyManager.instance.importPrivateKey(self.privateKeyTv.text, passwd:self.passwdTf.text!) { (isSuccess, error) in
            if isSuccess, let address = KeyManager.instance.address {
                MainABI.instance.getInfo(address: address, complete: { (model, err) in
                    CLLHud.hide(for: self.view)
                    if let m = model {
                        if m.registed {
                            MeController.refresh()
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.showInputNikeNameUI()
                        }
                    } else {
                        CLLHud.showTipMessage((err != nil) ? err!.localizedDescription : "登录失败")
                    }
                })
            } else {
                CLLHud.hide(for: self.view)
                CLLHud.showTipMessage((error != nil) ? error!.localizedDescription : "登录失败")
            }
        }
    }
    
    private func informate() {
        guard let nickName = self.nickNameTf.text else {
            CLLHud.showTipMessage("请输入昵称")
            return
        }
        CLLHud.showLoading(to: self.view, animated: true)
        PPS_ipfs.addDict(["nickName":nickName]) { (ipfsHash, error) in
            guard let hash = ipfsHash, !hash.isEmpty else {
                CLLHud.hide(for: self.view)
                CLLHud.showTipMessage((error != nil) ? error!.localizedDescription : "资料完善失败")
                return
            }
            MainABI.instance.write(MainABI.Write.register(ipfsHash: hash), complete: { (hash, error) in
                CLLHud.hide(for: self.view)
                if let hs = hash, !hs.isEmpty {
                    MeController.refresh()
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                CLLHud.showTipMessage((error != nil) ? error!.localizedDescription : "资料完善失败")
            })
        }
    }
}

extension LoginController: UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func textFeildDidChanged(tf: UITextField) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.privateKeyPlaceTv.isHidden = self.privateKeyTv.text.count > 0
    }
}
