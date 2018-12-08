//
//  AppDelegate.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CLLBasic
import Ipfs

let kMathWalletLogin = "kMathWalletLogin"
let kMathWalletTransfer = "kMathWalletTransfer"
let kMathWalletCustomTransfer = "kMathWalletCustomTransfer"

//let trustSDK = TrustSDK(callbackScheme: "LiananTechHouse")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        MathWalletAPI.registerAppURLSchemes("LiananTechHouse")
        Ipfs.shared().setBase(address: "http://192.168.1.160")
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = self.getMainController()
        window?.makeKeyAndVisible()
        
        Test.addTestButton()
        
        return true
    }
    
    private func getMainController() -> UIViewController {
        let tabBar = UITabBar.appearance()
        tabBar.backgroundColor = UIColor.white
        tabBar.backgroundImage = UIImage.init(named: "tabbarWhiteBackground")
        tabBar.tintColor = UIColor.theme
        tabBar.barTintColor = UIColor.theme
        tabBar.isTranslucent = false
        
        let tabBarController = CLLTabBarController.init()
        // 首页
        let home = HouseListController.init()
        home.title = home.viewModel.title
        tabBarController.setupChildVC(CLLNavigationController.init(rootViewController: home), tabBarTitle: home.title!, image: UIImage.init(named: "tabBar_home_icon")!, selectedImage: UIImage.init(named: "tabBar_home_click_icon")!)
        // 我
        let me = MeController.init()
        me.title = me.viewModel.title
        tabBarController.setupChildVC(CLLNavigationController.init(rootViewController: me), tabBarTitle: me.title!, image: UIImage.init(named: "tabBar_mine_icon")!, selectedImage: UIImage.init(named: "tabBar_mine_click_icon"
        )!)
        return tabBarController
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true//trustSDK.handleCallback(url: url)
        
//        let handle: Bool = MathWalletAPI.handle(url) { (resq) in
//            if (resq == nil) { return }
//            print("\(String(describing: resq!.data))")
//            if (resq!.data["action"] as? String == "login") {
//                // 登录
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMathWalletLogin), object: resq)
////                NSNotificationCenter.defaultCenter.postNotificationName:kMathWalletLogin object:resq];
//            } else if (resq!.data["action"] as? String == "transfer") {
//                // 转账
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMathWalletTransfer), object: resq)
////                [[NSNotificationCenter defaultCenter] postNotificationName:kMathWalletTransfer object:resq];
//            } else if (resq!.data["action"] as? String == "transaction") {
//                // 自定义转账
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMathWalletCustomTransfer), object: resq)
////                [[NSNotificationCenter defaultCenter] postNotificationName:kMathWalletCustomTransfer object:resq];
//            }
//        }
//        return handle
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

