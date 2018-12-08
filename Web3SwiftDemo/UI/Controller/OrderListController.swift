//
//  OrderListController.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/30.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import CLLHud

class OrderListCell: HouseListCell {
    
    private var timeLabel: UILabel!
    var order: OrderModel? {
        didSet {
            self.updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.timeLabel = CLLViewTool.makeLabel(with: UIFont.less, textColor: UIColor.hintText, block: { (label) in
            label.frame =  self.priceLabel.frame
            label.textAlignment = .right
        })
        self.contentView.addSubview(self.timeLabel)
    }
    
    private func updateUI() -> Void {
        if let order = self.order {
            self.house = order.house
            if order.time.count > 0 {
                self.timeLabel.isHidden = false
                self.timeLabel.text = order.time
                self.timeLabel.sizeToFit()
                self.timeLabel.bottom = self.priceLabel.bottom
                self.timeLabel.right = Screen.width - Screen.leftRightMargin
                self.priceLabel.width = self.timeLabel.left - self.priceLabel.left
            } else {
                self.timeLabel.isHidden = true
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class OrderListController: CLLBaseViewController {
    
    private let ident = "OrderListCell"
    private var tableView: UITableView!
    private var arrData: [OrderModel] = []
    var viewModel: OrderListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.title
        self.view.backgroundColor = UIColor.white
        
        self.tableView = UITableView.init(frame: Screen.showRect, style: .plain)
        self.tableView.delegate = self as UITableViewDelegate;
        self.tableView.dataSource = self as UITableViewDataSource;
        self.tableView.backgroundColor = UIColor.rgb(0, 0, 0, alpha: 0)
        self.tableView.separatorStyle = .none
        self.tableView.register(OrderListCell.classForCoder(), forCellReuseIdentifier: ident)
        self.view.addSubview(self.tableView)
        
//        self.arrData = Array.init(repeating: OrderModel.testData(), count: 10)
        self.update()
    }
    
    func update(isTips: Bool = true) -> Void {
        CLLHud.showLoading(to: self.view, animated: true)
        weak var weakSelf = self
        self.viewModel.getOrders { (orders, error) in
            if weakSelf == nil { return }
            CLLHud.hide(for: weakSelf!.view)
            guard let ords = orders, !ords.isEmpty else {
                CLLHud.showWarnMessage(error?.localizedDescription)
                return
            }
            weakSelf!.arrData = ords
            weakSelf!.tableView.reloadData()
        }
    }
    
    deinit {
        print("\(self.classForCoder)被释放")
    }
}

extension OrderListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderListCell.cellHeight(self.arrData[indexPath.row].house)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OrderListCell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as! OrderListCell
        cell.order = self.arrData[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: OrederDetailController = OrederDetailController.init()
        vc.order = self.arrData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
