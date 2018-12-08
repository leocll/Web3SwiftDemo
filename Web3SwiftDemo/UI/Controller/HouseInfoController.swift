//
//  HouseInfoController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/5.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud

class HouseInfoController: CLLBaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTf: UITextField!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceTf: UITextField!
    
    @IBOutlet weak var bedRoomLabel: UILabel!
    @IBOutlet weak var bedRoomTf: UITextField!
    
    @IBOutlet weak var toiletLabel: UILabel!
    @IBOutlet weak var toiletTf: UITextField!
    
    @IBOutlet weak var airLabel: UILabel!
    @IBOutlet weak var airSwitch: UISwitch!
    
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    @IBOutlet weak var bunkLabel: UILabel!
    @IBOutlet weak var bunkSwitch: UISwitch!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTv: UITextView!
    @IBOutlet weak var titlePlaceTv: UITextView!
    
    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    private var image: UIImage?
    private var albumHelper: CLLAlbumHelper!
    public var viewModel: HouseInfoViewModel = HouseInfoViewModel.init()
    
    init() {
        super.init(nibName: "HouseInfoController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.viewModel.title
        self.view.backgroundColor = UIColor.white
        
        self.albumHelper = CLLAlbumHelper.init()
        self.albumHelper.bindChoseImageBlcok({ [weak self] (image) in
            self?.pictureImageView.image = image;
            self?.image = image
        })
        setupUI()
    }
    
    private func setupUI() {
        scrollView.delegate = self
        let arrLabel: [UILabel] = [cityLabel, priceLabel, bedRoomLabel, toiletLabel, airLabel, wifiLabel, bunkLabel, titleLabel, pictureLabel]
        for label in arrLabel {
            label.font = UIFont.normal
            label.textColor = UIColor.normalText
            label.textShadow()
        }
        let arrTextfield: [UITextField] = [cityTf, priceTf, bedRoomTf, toiletTf]
        for tf in arrTextfield {
            tf.font = UIFont.less
            tf.textColor = UIColor.normalText
            tf.delegate = self
        }
        titleTv.font = UIFont.less
        titleTv.textColor = UIColor.normalText
        titleTv.delegate = self
        titlePlaceTv.isEditable = false
        
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(touchesImageView)))
        
        let button = CLLViewTool.makeButton { (btn) in
            btn.titleLabel?.font = UIFont.bigger
            btn.setTitle(self.viewModel.business.title, for: .normal)
            btn.setTitleColor(UIColor.normalText, for: .normal)
            btn.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
            btn.textShadow()
            btn.addTarget(self, action: #selector(self.touchesButton), for: .touchUpInside)
            btn.sizeToFit()
            btn.height = 44
            btn.right = Screen.width - Screen.leftRightMargin*2;
            btn.bottom = Device.iPhoneX ? Screen.showHeight : (Screen.showHeight - 30)
        }
        self.view.addSubview(button)
        guard let house = self.viewModel.house else {
            return
        }
        cityTf.isEnabled = false
        cityTf.text = house.city
        priceTf.text = String(house.price)
        bedRoomTf.text = String(house.bedroom)
        toiletTf.text = String(house.toilet)
        airSwitch.isOn = house.airConditioner
        wifiSwitch.isOn = house.network
        bunkSwitch.isOn = house.bunk
        titleTv.text = house.title
        textViewDidChange(titleTv)
        pictureImageView.setImage(withIpfsHash: house.imageUrl, placeholderImage: UIImage.placeholder)
    }
    
    @objc func touchesImageView() {
        self.albumHelper.show()
    }
    
    @objc func touchesButton() {
        UIAlertController.passwordVerifyAlert {
            switch self.viewModel.byWho {
            case .add: self.add()
            case .edit: self.edit()
            }
        }
    }
    
    private func veri() -> HouseModel? {
        guard let city = self.cityTf.text, !city.isEmpty else {
            CLLHud.showTipMessage("请输入城市")
            return nil
        }
        guard let price = self.priceTf.text, !price.isEmpty else {
            CLLHud.showTipMessage("请输入价格")
            return nil
        }
        guard let bedroom = self.bedRoomTf.text, !bedroom.isEmpty else {
            CLLHud.showTipMessage("请输入室")
            return nil
        }
        guard let toilet = self.toiletTf.text, !toilet.isEmpty else {
            CLLHud.showTipMessage("请输入卫")
            return nil
        }
        guard let title = self.titleTv.text, !title.isEmpty else {
            CLLHud.showTipMessage("请输入标题")
            return nil
        }
        if self.image == nil, self.viewModel.house == nil {
            CLLHud.showTipMessage("请选择图片")
            return nil
        }
        let house = HouseModel.init()
        house.city = city
        house.price = Int(price) ?? 0
        house.bedroom = Int(bedroom) ?? 0
        house.toilet = Int(toilet) ?? 0
        house.airConditioner = self.airSwitch.isOn
        house.network = self.wifiSwitch.isOn
        house.bunk = self.bunkSwitch.isOn
        house.title = title
        house.imageUrl = self.viewModel.house?.imageUrl
        house.seller = KeyManager.instance.address
        return house
    }
    
    private func edit() {
        guard let house = self.veri() else {
            return
        }
        CLLHud.showLoading(to: self.view, animated: true)
        self.viewModel.edit(image: self.image, house: house) { [weak self] (success, error) in
            CLLHud.hide(for: self?.view, animated: true)
            if success {
                CLLHud.showTipMessage("修改成功")
                self?.navigationController?.popViewController(animated: true)
            } else {
                CLLHud.showTipMessage(error != nil ? error?.localizedDescription : "修改失败")
            }
        }
    }
    
    private func add() {
        guard let house = self.veri() else {
            return
        }
        CLLHud.showLoading(to: self.view, animated: true)
        self.viewModel.add(image: self.image!, house: house) { [weak self] (success, error) in
            CLLHud.hide(for: self?.view, animated: true)
            if success {
                CLLHud.showTipMessage("添加成功")
                self?.navigationController?.popViewController(animated: true)
            } else {
                CLLHud.showTipMessage(error != nil ? error?.localizedDescription : "添加失败")
            }
        }
    }
}

extension HouseInfoController: UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.titlePlaceTv.text = textView.text.count>0 ? "" : "请请输入标题"
    }
}
