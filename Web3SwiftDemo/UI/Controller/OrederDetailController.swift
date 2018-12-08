//
//  OrederController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud

class OrederDetailController: CLLBaseViewController {
    
    class OrderDetailView: DetailView {
        private var timeItem: DetailItemView!
        override func createUI() {
            super.createUI()
            // 时间
            self.timeItem = DetailItemView.init(title: "时间")
            self.addSubview(self.timeItem, withIndex: NSNumber.init(value: 6))
        }
        override func update<T>(data: T?) {
            if data != nil,let order: OrderModel = data as? OrderModel {
                self.timeItem.update(content: order.time)
                super.update(data: order.house)
            } else {
                self.timeItem.update(content: nil)
                super.update(data: data)
            }
        }
    }
    
    public var order: OrderModel?
    private var mainView: OrderDetailView!
    private var button1: UIButton!
    private var button2: UIButton!
    private var textLabel: UILabel!
    
    deinit {
        print("\(self.classForCoder)被释放")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "订单详情"
        self.view.backgroundColor = UIColor.white
        createUI()
    }
    private func createUI() {
        self.mainView = OrderDetailView.init(frame: Screen.showXRect)
        self.view.addSubview(self.mainView)
        // 按钮1
        self.button1 = CLLViewTool.makeButton({ (btn) in
            btn.titleLabel?.font = UIFont.bigger;
            btn.setTitleColor(UIColor.normalText, for: .normal)
            btn.addTarget(self, action: #selector(self.touchesButton), for: .touchUpInside)
            btn.isHidden = true
            btn.textShadow()
            self.mainView.operateView?.addSubview(btn)
        })
        // 按钮2
        self.button2 = CLLViewTool.makeButton({ (btn) in
            btn.titleLabel?.font = UIFont.bigger;
            btn.setTitleColor(UIColor.normalText, for: .normal)
            btn.addTarget(self, action: #selector(self.touchesButton), for: .touchUpInside)
            btn.isHidden = true
            btn.textShadow()
            self.mainView.operateView?.addSubview(btn)
        })
        
        self.textLabel = CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: nil)
        self.textLabel.textShadow()
        self.textLabel.numberOfLines = 2
        self.mainView.operateView?.addSubview(self.textLabel)

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.button1.translatesAutoresizingMaskIntoConstraints = false
        self.button2.translatesAutoresizingMaskIntoConstraints = false
        
        self.textLabel.leftAnchor.constraint(equalTo: self.textLabel.superview!.leftAnchor, constant: Screen.leftRightMargin).isActive = true
        self.textLabel.topAnchor.constraint(equalTo: self.textLabel.superview!.topAnchor).isActive = true
        self.textLabel.heightAnchor.constraint(equalTo: self.textLabel.superview!.heightAnchor).isActive = true
        self.textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.button1.leftAnchor.constraint(equalTo: self.textLabel.rightAnchor, constant: Screen.leftRightMargin).isActive = true
        self.button1.topAnchor.constraint(equalTo: self.button1.superview!.topAnchor).isActive = true
        self.button1.heightAnchor.constraint(equalTo: self.button1.superview!.heightAnchor).isActive = true
        
        self.button2.leftAnchor.constraint(equalTo: self.button1.rightAnchor, constant: Screen.leftRightMargin).isActive = true
        self.button2.topAnchor.constraint(equalTo: self.button2.superview!.topAnchor).isActive = true
        self.button2.heightAnchor.constraint(equalTo: self.button2.superview!.heightAnchor).isActive = true
        self.button2.rightAnchor.constraint(equalTo: self.button2.superview!.rightAnchor, constant: -Screen.leftRightMargin).isActive = true
        
        updateUI()
    }
    private func updateUI() {
        if let text: String = self.order?.actions?.1.text {
            self.button2.isHidden = false
            self.button2.setTitle(text, for: .normal)
        } else {
            self.button2.isHidden = true
        }
        if let text: String = self.order?.actions?.0?.text {
            self.button1.isHidden = false
            self.button1.setTitle(text, for: .normal)
        } else {
            self.button1.isHidden = true
        }
        self.textLabel.text = self.order?.desc
        self.mainView.update(data: self.order)
    }
    @objc func touchesButton(btn: UIButton) {
        UIAlertController.passwordVerifyAlert {
            var action: OrderModel.Action? = nil
            if btn == self.button1 {
                action = self.order?.actions?.0
            } else {
                action = self.order?.actions?.1
            }
            if let action = action {
                switch action {
                case .refund:
                    self.write(.refundApply(orderAddress: self.order!.orderAddress!))
                    print("已申请退款")
                case .agreeRefund:
                    self.write(.refundAgree(orderAddress: self.order!.orderAddress!, endTime: String(Date().timeIntervalSince1970 * 1000)))
                    print("已同意退款")
                case .done:
                    self.write(.orderDone(orderAddress: self.order!.orderAddress!, endTime: String(Date().timeIntervalSince1970 * 1000)))
                    print("订单已完成")
                }
            }
        }
    }
    
    func write(_ wr: MainABI.Write) {
        CLLHud.showLoading(to: self.view, animated: true)
        MainABI.instance.write(wr) { (tx, error) in
            CLLHud.hide(for: self.view)
            guard let tx = tx, !tx.isEmpty, error == nil else {
                CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "操作失败")
                return
            }
            MeController.refresh()
            CLLHud.showTipMessage(error != nil ? error!.localizedDescription : "操作成功")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
