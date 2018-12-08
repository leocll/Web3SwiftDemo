//
//  MeController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import Web3swift
import CLLHud
import EthereumAddress
import MJRefresh

class MeListCell: UITableViewCell {
    public static let cellHeight = FitXLMS(44, 44, 44, 40)
    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var descLabel: UILabel!
    var arrowImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none

        self.iconImageView = CLLViewTool.makeImageView(UIImage.placeholder, block: nil)
        self.iconImageView.left = Screen.leftRightMargin
        self.iconImageView.size = CGSize.init(width: 24, height: 24)
        self.iconImageView.centerY = MeListCell.cellHeight * 0.5
        self.contentView.addSubview(self.iconImageView)
        
        self.titleLabel = CLLViewTool.makeLabel(with: UIFont.normal, textColor: UIColor.normalText, block: nil)
        self.titleLabel.left = self.iconImageView.right + Screen.leftRightMargin
        self.titleLabel.height = MeListCell.cellHeight
        self.titleLabel.width = self.width
        self.contentView.addSubview(self.titleLabel)
        
        self.descLabel = CLLViewTool.makeLabel(with: UIFont.less, textColor: UIColor.lightText, block: nil)
        self.descLabel.numberOfLines = 2
        self.descLabel.textAlignment = .right
        self.descLabel.height = MeListCell.cellHeight
        self.descLabel.width = self.width
        self.contentView.addSubview(self.descLabel)

        self.arrowImageView = CLLViewTool.makeImageView(UIImage.arrowRighe, block: nil)
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.centerY = MeListCell.cellHeight * 0.5
        self.arrowImageView.right = Screen.width - Screen.leftRightMargin
        self.contentView.addSubview(self.arrowImageView)
        
        self.descLabel.right = self.arrowImageView.left - Screen.leftRightMargin
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.leftAnchor.constraint(equalTo: self.iconImageView.rightAnchor, constant: Screen.leftRightMargin).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.descLabel.superview!.topAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.descLabel.superview!.bottomAnchor).isActive = true
        
        self.descLabel.leftAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: Screen.leftRightMargin).isActive = true
        self.descLabel.rightAnchor.constraint(equalTo: self.arrowImageView.leftAnchor, constant: -Screen.leftRightMargin).isActive = true
        self.descLabel.topAnchor.constraint(equalTo: self.descLabel.superview!.topAnchor).isActive = true
        self.descLabel.bottomAnchor.constraint(equalTo: self.descLabel.superview!.bottomAnchor).isActive = true
        
        self.contentView.addSubview(CLLViewTool.makeHorizontalLine({ (line) in
            line.width = Screen.width
            line.left = self.titleLabel.left
            line.height = 0.5
            line.backgroundColor = UIColor.darkLine
        }))
        self.contentView.addSubview(CLLViewTool.makeHorizontalLine({ (line) in
            line.width = Screen.width
            line.left = self.titleLabel.left
            line.height = 0.5
            line.top = MeListCell.cellHeight
            line.backgroundColor = UIColor.darkLine
        }))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MeController: CLLBaseViewController {
    
    private let ident = "MeListCell"
    private let headerIdent = "HeaderFooterView"
    private var tableView: UITableView!
    
    let viewModel: MeViewModel = {
        return MeViewModel.init()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.viewModel.title
        self.view.backgroundColor = UIColor.white
        
        self.tableView = UITableView.init(frame: Screen.showRect, style: .grouped)
        self.tableView.height = Screen.showXHeight - (self.tabBarController != nil ? self.tabBarController!.tabBar.height : Screen.xBottomMargin)
        self.tableView.delegate = self as UITableViewDelegate;
        self.tableView.dataSource = self as UITableViewDataSource;
        self.tableView.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
        self.tableView.separatorStyle = .none
        self.tableView.register(MeListCell.classForCoder(), forCellReuseIdentifier: ident)
        self.tableView.register(HeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: headerIdent)
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.update()
        })
        self.view.addSubview(self.tableView)
        
        self.update()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("RefreshMeController"), object: nil, queue: nil) { [weak self] (_) in
            self?.update()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.height = self.view.height
    }
    
    static func refresh() {
        NotificationCenter.default.post(name: NSNotification.Name.init("RefreshMeController"), object: nil)
    }
    
    func update() {
        self.viewModel.updateUserInfo { [weak self] () in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.reloadData()
        }
        self.viewModel.updateGoods { [weak self] () in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.reloadData()
        }
        self.viewModel.updateOrderes { [weak self] () in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit {
        print("\(self.classForCoder)被释放")
    }
}

extension MeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MeListCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MeListCell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as! MeListCell
        let item: MeViewModel.MeItem = self.viewModel.items[indexPath.section][indexPath.row]
        cell.iconImageView.image = item.item.icon
        cell.titleLabel.text = item.item.title
        cell.descLabel.text = item.desc
        cell.arrowImageView.isHidden = !item.arrow
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: MeViewModel.MeItem = self.viewModel.items[indexPath.section][indexPath.row]
        item.action?(item, self.viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section==0 ? 20 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    class HeaderFooterView: UITableViewHeaderFooterView {
        let topLine: UIView = CLLViewTool.makeHorizontalLine { (line) in
            line.backgroundColor = UIColor.darkLine
            line.height = 0.5
            line.width = Screen.width
        }
        let bottomLine: UIView = CLLViewTool.makeHorizontalLine { (line) in
            line.backgroundColor = UIColor.darkLine
            line.height = 0.5
            line.width = Screen.width
        }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            self.contentView.addSubview(topLine)
            self.contentView.addSubview(bottomLine)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func layoutSubviews() {
            bottomLine.top = self.height
            self.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
            self.backgroundView?.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
            self.contentView.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: HeaderFooterView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdent) as? MeController.HeaderFooterView
        if  view == nil {
            view = HeaderFooterView.init(reuseIdentifier: headerIdent)
        }
        view?.topLine.isHidden = true
        view?.bottomLine.isHidden = false
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view: HeaderFooterView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdent) as? MeController.HeaderFooterView
        if  view == nil {
            view = HeaderFooterView.init(reuseIdentifier: headerIdent)
        }
        view?.topLine.isHidden = false
        view?.bottomLine.isHidden = true
        return view
    }
}
