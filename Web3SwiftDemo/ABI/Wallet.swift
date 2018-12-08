//
//  Test.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import Web3swift
import BigInt
import ObjectMapper
import Result
import KeychainSwift

class Test: NSObject {
    var i: Int = 0
    
    static func addTestButton() {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.red
        btn.frame = CGRect.init(x: 0, y: 200, width: 40, height: 40)
        btn.addTarget(self, action: #selector(self.test), for: .touchUpInside)
        UIApplication.shared.keyWindow?.addSubview(btn)
    }
    
//    var airConditioner: Bool = false    // 空调
//    var bedroom: Int = 0        // 卧室
//    var bunk: Bool = false      // 耀层
//    var city: String?           // 所属城市
//    var imageUrl: String?        // 图片
//    var network: Bool = false   // wifi
//    var price: Int = 0          // 价格，单位通过后面的walletType指定
//    var searchWalletType: Int = 0     // 默认使用0，即以太坊，1代表btc，2代表bch
//    var seller: String?         // 卖家以太坊地址，e.g. "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0" "0x02CA844F54f0cF4e36eF6214894Ae58fE6560076"
//    var titile: String?         // 标题
//    var toilet: Int = 0         // 卫
    
    static public func readInfos<T: Mappable>(method: String, parameters: [AnyObject] = [AnyObject](), options: Web3Options? = nil, type: T.Type, complete:((T?, [String: Any]?, Error?) -> Void)?) {
        print("")
    }
    
    static public func readInfo<T: Mappable>(method: String, parameters: [AnyObject] = [AnyObject](), options: Web3Options? = nil, type: T.Type? = nil, complete:((T?, [String: Any]?, Error?) -> Void)?) {
        print("")
    }
    
    static var keychain: KeychainSwift = KeychainSwift.init()
    @objc static func test() {
        UIAlertController.showInputPasswordAlert(nil)
        
//        if let v = keychain.get("leocll") {
//            print(v)
//        }
//        keychain.set("123", forKey: "leocll")
        
//        MathWalletTest.register()
        
        
//        MainABI.instance.test()
        
//        let data = ["nickName":"leocll"].jsonData! //UIImage.init(named: "XRPlaceholder")!.jpegData(compressionQuality: 1)!
//        trustSDK.signMessage(data) { (res: Result<Data, WalletError>) in
//
//        }
//        PPS_ipfs.addImage(UIImage.init(named: "XRPlaceholder")!) { (hash, error) in
//            if let h = hash {
//                print("图片hash：\(h)")
//                let arr: [String] = ["华润时光里","阿玛尼艺术公寓","龙湖天街"]
//                for item in arr {
//                    let houseJson: [String: Any] = ["airConditioner": true,
//                                                    "bedroom": 3,
//                                                    "bunk": true,
//                                                    "city": "chengdu",
//                                                    "imageUrl": "\(h)",
//                        "network": true,
//                        "price": 9,
//                        "searchWalletType": "0",
//                        "seller": "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0",
//                        "title": "\(item) 免费寄存行李|下楼就是春熙路太古里市中心/天府广场/宽窄巷子/宜家清新风格",
//                        "toilet": 1]
//                    PPS_ipfs.addDict(houseJson, complete: { (hash, error) in
//                        print("房源hash：\(hash!)")
//                    })
//                }
//            }
//        }
        
//        self.readInfos(method: "fdasfa", type: MainABI.MainABI_OrderInfo.self, complete: nil)
//        self.readInfo(method: "fdasfads", type: MainABI.MainABI_OrderInfo.self, complete: nil)
        
//        MainABI.instance.getInfo { (model, error) in
//            
//        }
//        MainABI.instance.getOrderInfo(orderAddress: "0x58F811848fcD04103A06c388A284496166F1cd94") { (model, error) in
//
//        }
        
    }
    
    func terere() {
//        let group = DispatchGroup()
//        for _ in 0 ..< 3 {
//            group.enter()
//            PPS_ipfs.cat { (_, _) in
//                group.leave()
//            }
//        }
//        group.notify(queue: DispatchQueue.main) {
//            print("3个任务完成了")
//        }
//
//        PPS_ipfs.cat { (_, _) in
//            print("单独任务完成了")
//        }
//
//        let group2 = DispatchGroup()
//        let queue2 = DispatchQueue.global()
//        for _ in 0 ..< 3 {
//            group2.enter()
//            queue2.async(group: group2) {
//                PPS_ipfs.cat { (_, _) in
//                    group2.leave()
//                }
//            }
//        }
//
//        group2.notify(queue: queue2) {
//            print("3个任务完成了")
//        }
//
//
//        let houseJson: [String: Any] = ["airConditioner": true,
//                         "bedroom": 3,
//                         "bunk": true,
//                         "city": "chengdu",
//                         "imageUrl": "QmV28in9a3wP896Ho789RUThro9yBKmmVG4KDKpTnuQNYo",
//                         "network": true,
//                         "price": 9,
//                         "searchWalletType": "0",
//                         "seller": "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0",
//                         "title": "华润时光里 免费寄存行李|下楼就是春熙路太古里市中心/天府广场/宽窄巷子/宜家清新风格",
//                         "toilet": 1]
//        PPS_ipfs.add(json: houseJson)
//
//        let json: [String: Any] = ["airConditioner": true,
//                                        "bedroom": 2,
//                                        "bunk": true,
//                                        "city": "chengdu",
//                                        "imageUrl": "QmV28in9a3wP896Ho789RUThro9yBKmmVG4KDKpTnuQNYo",
//                                        "network": true,
//                                        "price": 10,
//                                        "searchWalletType": "0",
//                                        "seller": "0x1C81c7ce952ff27e46e8BAD6CB39405d9F201fE0",
//                                        "title": "西南国际城 免费寄存行李|下楼就是春熙路太古里市中心/天府广场/宽窄巷子/宜家清新风格",
//                                        "toilet": 2]
//        PPS_ipfs.add(json: json)
    
//        PPS_ipfs.add(Data())
//        PPS_ipfs.cat { (res, err) in
//            print("请求完成")
//        }
        
//        PPS_ipfs.cat(paths: ["QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg","QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg"], once: nil, complete: nil)
        
//        let paths = ["QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg","QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg"]//NSArray.init(objects: "QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg", count: 3)
//        let callbackQueue = DispatchQueue.main
        
//        PPS_ipfs.cat(paths: paths, callbackQueue: callbackQueue, once: { (moyaResponse, error) in
//            print("请求完成\(++i)")
//        }) { (res, err) in
//            print("请求完成")
//        }
        
//        PPS_ipfs.cat(paths: ["QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg","QmadBJj6t6yonXdyC4Wt1hwZykrRsZVdxoLF9ny2x37xJg"], once: { (m, error) in
//            print("请求完成某个请求\(Thread.current)")
//        }) { (ms, err) in
//            print("请求完成\(Thread.current)")
//        }
//        print("已发出请求\(Thread.current)")
        
//        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
//        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .localDomainMask, true)[0])")
//        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .networkDomainMask, true)[0])")
//        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .systemDomainMask, true)[0])")
//        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])")

        
//        MainABI.instance.getGoods(complete: nil)
//        print("正在发送\(Thread.current)")
//        DispatchQueue.global().async {
//            MainABI.instance.getInfo { (model, error) in
//                print("请求完成\(Thread.current)")
//                if model != nil {
//
//                } else {
//
//                }
//            }
//        }
//        print("已发出请求\(Thread.current)")
//        MainABI.instance.getOrders(complete: nil)
//        MainABI.instance.getIndexGoods(complete: nil)
//        MainABI.instance.getNumber(complete: nil)
        
//        MainABI.instance.getOrderInfo { (model, error) in
//
//        }
        
    }
    
//    static func balance() -> Void {
//        
////        let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
//        let test = EthereumAddress("0x68b05b7e1b003dF1F9ee3F59dcDf240c2ae527AC")!
//        
////        let web3Main = Web3.InfuraMainnetWeb3()
//        let web3Custom = web3.init(provider: Web3HttpProvider.init(URL.init(string: "http://45.62.114.149:8545")!, network: .Rinkeby, keystoreManager: nil)!)
//        let balanceResult = web3Custom.eth.getBalance(address: test)
//        guard case .success(let balance) = balanceResult else {
//            print("\(balanceResult.description)")
//            return
//        }
//        print("\(balance)")
//        
//        print("转化结果：+\(Web3.Utils.formatToEthereumUnits(balance) ?? "转化失败")")
////        print("eth = \(String(describing: Web3.Utils.parseToBigUInt(String(balance), units: .eth)))")
////        print("wei = \(String(describing: Web3.Utils.parseToBigUInt(String(balance), units: .wei)))")
////        print("Gwei = \(String(describing: Web3.Utils.parseToBigUInt(String(balance), units: .Gwei)))")
//    }
//    
//    static func balanceERC() -> Void {
//        // ERC20
//        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
//        let contractAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")! // w3s token on Ethereum mainnet
//        let contract = web3.init(provider: InfuraProvider.init(.Mainnet)!).contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)! // utilize precompiled ERC20 ABI for your concenience
//        
//        guard let w3sBalanceResult = contract.method("balanceOf", parameters: [coldWalletAddress] as [AnyObject], options: nil/*options*/)?.call(options: nil) else {
//            return
//        } // encode parameters for transaction
//        guard case .success(let w3sBalance) = w3sBalanceResult, let bal = w3sBalance["0"] /*as? BigUInt*/ else {
//            return
//        } // w3sBalance is [String: Any], and parameters are enumerated as "0", "1", etc in order of being returned. If returned parameter has a name in ABI, it is also duplicated
////        print("w3s token balance = " + String(bal))
//        for item in w3sBalance {
//            print("w3sBalance[\(item.key)] = \(item.value)")
//        }
//        print("w3s token balance = \(bal)")
//    }
}
