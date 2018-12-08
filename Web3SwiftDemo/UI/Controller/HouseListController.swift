//
//  HouseListController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud
import MJRefresh

class HouseListCell: UITableViewCell {
    
    private let leftRingSpacing = Screen.leftRightMargin
    private let topBottomSpacing = Screen.topBottomMargin
    
    private var houseImageView: UIImageView!
    private var titleLabel: UILabel!
    private var regionLabel: UILabel!
    private var descLabel: UILabel!
    var priceLabel: UILabel!
    private var bottomLine: UIView!
    
    var house:HouseModel? {
        didSet {
            self.updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.width = Screen.width
        // 图片
        self.houseImageView = CLLViewTool.makeImageView(UIImage.placeholder, block: { (imageView: UIImageView) in
            imageView.frame = CGRect.init(x: self.leftRingSpacing, y: self.topBottomSpacing, width: FitScreen(120), height: FitScreen(80))
        })
        self.contentView.addSubview(self.houseImageView)
        // 标题
        self.titleLabel = CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: { (label: UILabel) in
            label.numberOfLines = 2
            label.top = self.houseImageView.top
            label.left = self.houseImageView.right + self.leftRingSpacing
            label.width = self.width - label.left - self.leftRingSpacing
        })
        self.contentView.addSubview(self.titleLabel)
        // 区域
        self.regionLabel = CLLViewTool.makeLabel(with: UIFont.mini, textColor: UIColor.lightText, block: { (label: UILabel) in
            label.top = self.titleLabel.bottom + 7
            label.left = self.titleLabel.left
            label.width = self.titleLabel.width
        })
        self.contentView.addSubview(self.regionLabel)
        // 描述
        self.descLabel = CLLViewTool.makeLabel(with: UIFont.mini, textColor: UIColor.lightText, block: { (label: UILabel) in
            label.top = self.regionLabel.bottom + 5
            label.left = self.titleLabel.left
            label.width = self.titleLabel.width
        })
        self.contentView.addSubview(self.descLabel)
        // 价格
        self.priceLabel = CLLViewTool.makeLabel(with: UIFont.mini, textColor: UIColor.lightText, block: { (label: UILabel) in
            label.top = self.descLabel.bottom + 5;
            label.left = self.titleLabel.left;
            label.width = self.titleLabel.width;
        })
        self.contentView.addSubview(self.priceLabel)
        
        self.height = self.houseImageView.bottom + self.topBottomSpacing;
        
        self.bottomLine = UIView.init(frame: CGRect.init(x: self.titleLabel.left, y: 0, width: Screen.width, height: 0.5))
        self.bottomLine.backgroundColor = UIColor.darkLine
        self.contentView.addSubview(self.bottomLine)
    }
    
    private func updateUI() {
        guard let house = self.house else {
            self.height = self.houseImageView.bottom + self.topBottomSpacing;
            self.bottomLine.bottom = self.height
            return
        }
        if let url = house.imageUrl {
            self.houseImageView.setImage(withIpfsHash: url, placeholderImage: UIImage.placeholder)
        }
        self.titleLabel.text = house.title
        self.regionLabel.text = house.city
        self.descLabel.text = house.desc
        self.priceLabel.text = String(house.price)
        
        if let text = self.titleLabel.text, text.count > 0 {
            self.titleLabel.width = self.width - self.titleLabel.left - self.leftRingSpacing
            self.titleLabel.sizeToFit()
        } else {
            self.titleLabel.height = self.titleLabel.font.lineHeight
        }
        self.regionLabel.top = self.titleLabel.bottom + 5;
        self.descLabel.top = self.regionLabel.bottom + 5;
        self.priceLabel.top = self.descLabel.bottom + 5;
        
        self.height = self.houseImageView.bottom>self.priceLabel.bottom ? self.houseImageView.bottom+self.topBottomSpacing : self.priceLabel.bottom+self.topBottomSpacing;
        self.bottomLine.bottom = self.height
    }
    
    private static let cell = HouseListCell.init(style: .default, reuseIdentifier: nil)
    static func cellHeight(_ house: HouseModel?) -> CGFloat {
        cell.house = house
        return cell.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HouseListController: CLLBaseViewController {
    
    private let ident = "HouseListCell"
    private var tableView: UITableView!
    private var arrData: [HouseModel] = []
    var viewModel: HouseListViewModel = HouseListViewModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.title
        if self.viewModel.rightBusiness != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: { (label) in
                label.text = self.viewModel.rightBusiness?.title
                label.textAlignment = .right
                label.sizeToFit()
                label.height = 44
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.touchesRightButton)))
            }))
        }
        self.view.backgroundColor = UIColor.white
        
        self.tableView = UITableView.init(frame: Screen.showRect, style: .plain)
        self.tableView.delegate = self as UITableViewDelegate;
        self.tableView.dataSource = self as UITableViewDataSource;
        self.tableView.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
        self.tableView.separatorStyle = .none
        self.tableView.register(HouseListCell.classForCoder(), forCellReuseIdentifier: ident)
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.update(isTips: false)
        })
        self.view.addSubview(self.tableView)

        self.update()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("RefreshHouseListController"), object: nil, queue: nil) { [weak self] (_) in
            self?.update()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.height = self.view.height
    }
    
    static func refresh() {
        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshHouseListController"), object: nil)
    }
    
    func update(isTips: Bool = true) -> Void {
        CLLHud.showLoading(to: self.view, animated: true)
        self.viewModel.getHouses { [weak self] (houses, error) in
            CLLHud.hide(for: self?.view)
            self?.tableView.mj_header.endRefreshing()
            guard let hss = houses, !hss.isEmpty else {
                CLLHud.showWarnMessage(error?.localizedDescription)
                return
            }
            self?.arrData = houses!
            self?.tableView.reloadData()
        }
    }
    
    @objc func touchesRightButton() {
        self.viewModel.rightBusiness?.action(nil)
    }
    
    deinit {
        print("\(self.classForCoder)被释放")
    }
}

extension HouseListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HouseListCell.cellHeight(self.arrData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HouseListCell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as! HouseListCell
        cell.house = self.arrData[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.rowBusiness.action(self.arrData[indexPath.row])
    }
}
