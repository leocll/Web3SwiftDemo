//
//  HouseDetailController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud

class HouseDetailController: CLLBaseViewController {

    private var mainView: DetailView!
    private var house: HouseModel?
    public var viewModel: HouseDetailViewModel?
    
    deinit {
        print("\(self.classForCoder)被释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.viewModel == nil {
            CLLHud.showTipMessage("viewModel is nil")
            return
        }
        self.title = self.viewModel?.title
        self.view.backgroundColor = UIColor.white
        if self.viewModel?.rightBusiness != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: { (label) in
                label.text = self.viewModel?.rightBusiness?.title
                label.textAlignment = .right
                label.sizeToFit()
                label.height = 44
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.touchesRightButton)))
            }))
        }
        
        self.mainView = DetailView.init(frame: self.view.bounds)
        self.view.addSubview(self.mainView)
        // 购买按钮
        if let text = self.viewModel?.bottomBusiness?.title {
            CLLViewTool.makeButton({ (btn) in
                btn.titleLabel?.font = UIFont.bigger;
                btn.setTitle(text, for: .normal)
                btn.setTitleColor(UIColor.normalText, for: .normal)
                btn.addTarget(self, action: #selector(self.touchesBuyBtn), for: .touchUpInside)
                btn.sizeToFit()
                btn.height = self.mainView.operateView?.height ?? 60
                btn.right = Screen.width - Screen.leftRightMargin;
                btn.textShadow()
                self.mainView.operateView?.addSubview(btn)
            })
        }
        
        self.house = self.viewModel?.house
        self.mainView.update(data: self.house)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("RefreshHouseDetailController"), object: nil, queue: nil) { [weak self] (noti) in
            guard let ipfsHash = noti.userInfo?["ipfsHash"] as? String else {
                return
            }
            self?.update(ipfsHash: ipfsHash)
        }
    }
    
    static func refresh(ipfsHash: String) {
        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshHouseDetailController"), object: nil, userInfo: ["ipfsHash": ipfsHash])
    }
    
    func update(ipfsHash: String) {
        CLLHud.showLoading(to: self.view, animated: true)
        self.viewModel?.update(ipfsHash: ipfsHash, complete: { [weak self] (house, error) in
            CLLHud.hide(for: self?.view)
            if let hus = house {
                self?.house = hus
                self?.mainView.update(data: self?.house)
            }
        })
    }
    
    @objc func touchesRightButton() {
        self.viewModel?.rightBusiness?.action?(self.house!)
    }

    @objc func touchesBuyBtn() {
        UIAlertController.passwordVerifyAlert {
            CLLHud.showLoading(to: self.view, animated: true)
            self.viewModel?.buy(complete: { (success, error) in
                if success {
                    CLLHud.showTipMessage("购买成功")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "购买失败")
                }
            })
        }
    }
}
