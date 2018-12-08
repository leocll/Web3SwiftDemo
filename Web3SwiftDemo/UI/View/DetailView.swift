//
//  DetailView.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic

class DetailView: CLLVerticalContentView {
    class DetailItemView: UIView {
        private var titleItem: UILabel!
        private var contentLabel: UILabel!
        
        init(title:String) {
            let frame =  CGRect.init(x: Screen.leftRightMargin, y: 0, width: Screen.width-Screen.leftRightMargin*2, height: 0)
            super.init(frame:frame)
            self.titleItem = CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: { (label) in
                label.text = title
                label.textShadow()
                label.width = frame.width
            })
            self.addSubview(self.titleItem)
            self.contentLabel = CLLViewTool.makeLabel(with: UIFont.mini, textColor: UIColor.hintText, block: { (label) in
                label.numberOfLines = 0
                label.width = frame.width
                label.top = self.titleItem.bottom + 15
            })
            self.addSubview(self.contentLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func update(content:String?) {
            if let cont = content, cont.count > 0 {
                self.contentLabel.text = cont
            } else {
                self.contentLabel.text = "暂无信息"
            }
            self.contentLabel.sizeToFit()
            self.height = self.contentLabel.bottom
        }
    }
    
    private var imageView: UIImageView!
    private var titleItem: DetailItemView!
    private var regionItem: DetailItemView!
    private var descItem: DetailItemView!
    private var priceItem: DetailItemView!
    private var _operateView: UIView?
    public var operateView: UIView? {
        set (newValue) {
            if let operate = _operateView {
                operate.removeFromSuperview()
                self.bottomMargin -= operate.height
            }
            if let new = newValue {
                _operateView = new
                self.bottomMargin += new.height
            } else {
                _operateView = nil
            }
        }
        get {
            return _operateView
        }
    }
    deinit {
        print("\(self.classForCoder)被释放")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func createUI() {
        let kOperationHeight: CGFloat = 60
        self.verMargin = 20
        self.bottomMargin = Screen.xBottomMargin + kOperationHeight
        // 图片
        self.imageView = CLLViewTool.makeImageView(UIImage.placeholder, block: { (imageView) in
            imageView.left = Screen.leftRightMargin
            imageView.width = Screen.width - Screen.leftRightMargin * 2
            imageView.height = imageView.width / 3 * 2
        })
        self.addSubview(self.imageView, withIndex: NSNumber.init(value: 1))
        // 标题
        self.titleItem = DetailItemView.init(title: "标题")
        self.addSubview(self.titleItem, withIndex: NSNumber.init(value: 2))
        // 区域
        self.regionItem = DetailItemView.init(title: "区域")
        self.addSubview(self.regionItem, withIndex: NSNumber.init(value: 3))
        // 描述
        self.descItem = DetailItemView.init(title: "描述")
        self.addSubview(self.descItem, withIndex: NSNumber.init(value: 4))
        // 价格
        self.priceItem = DetailItemView.init(title: "价格")
        self.addSubview(self.priceItem, withIndex: NSNumber.init(value: 5))
        // 操作视图
        _operateView = UIView.init()
        self.operateView!.width = Screen.width
        self.operateView!.height = kOperationHeight
        self.operateView!.bottom = Screen.showHeight
        self.operateView!.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
        self.addSubview(self.operateView!)
    }
    public func update<T>(data: T?) {
        let house: HouseModel? = data as? HouseModel
        if let url = house?.imageUrl {
            self.imageView.setImage(withIpfsHash: url, placeholderImage: UIImage.placeholder)
        }
        self.titleItem.update(content:house?.title)
        self.regionItem.update(content:house?.city)
        self.descItem.update(content:house?.desc)
        self.priceItem.update(content:(house != nil) ? String(house!.price) : nil)
        self.relayoutSubviews()
    }
}
