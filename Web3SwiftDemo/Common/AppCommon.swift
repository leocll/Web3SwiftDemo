//
//  AppCommon.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit

func iOS(_ sys: CGFloat) -> Bool {
    if let csys: Float = Float(UIDevice.current.systemVersion) {
        return sys >= CGFloat(csys)
    } else {
        return false
    }
}

public func FitScreen(_ size: CGFloat) -> CGFloat {
    var asize = size
    Screen.comparePhone6(ascend: {
        asize *= 1.05
    }) {
        asize *= 0.9
    }
    return asize
}

public func FitXLMS(_ X: CGFloat, _ L: CGFloat, _ M: CGFloat, _ S: CGFloat) -> CGFloat {
    if Device.iPhoneX { return X }
    var asize = M
    Screen.comparePhone6(ascend: {
        asize = L
    }) {
        asize = S
    }
    return asize
}

public func FitFont(_ size: CGFloat) -> CGFloat {
    var asize = size
    Screen.comparePhone6(ascend: {
        asize += 1
    }) {
        asize -= 1
    }
    Screen.comparePhone6(ascend: {
    }, same: nil) {
    }
    return asize
}

extension UIImage {
    open class var placeholder: UIImage! { get { return UIImage.init(named: "placeholder") }}
    open class var arrowRighe: UIImage! { get { return UIImage.init(named: "ab_arrow_right") }}
}

extension UIFont {
    open class var bigger: UIFont { get { return UIFont.systemFont(ofSize: FitFont(17)) } }
    open class var normal: UIFont { get { return UIFont.systemFont(ofSize: FitFont(15)) } }
    open class var less: UIFont { get { return UIFont.systemFont(ofSize: FitFont(14)) } }
    open class var mini: UIFont { get { return UIFont.systemFont(ofSize: FitFont(12)) } }
}

extension UIColor {
    open class var theme: UIColor { get { return UIColor.rgb(51, 51, 51) }}
    open class var normalText: UIColor { get { return UIColor.rgb(51, 51, 51) }}
    open class var lightText: UIColor { get { return UIColor.rgb(152, 152, 152) }}
    open class var hintText: UIColor { get { return UIColor.rgb(130, 130, 130) }}
    open class var lightBackground: UIColor { get { return UIColor.rgb(250, 250, 250) }}
    open class var lightLine: UIColor { get { return UIColor.rgb(230, 230, 230) }}
    open class var darkLine: UIColor { get { return UIColor.rgb(200, 200, 200) }}
    open class var placeholder: UIColor { get { return UIColor.rgb(152, 152, 152, alpha: 0.3) }}
    open class var touchColor: UIColor { get { return UIColor.rgb(58, 152, 248) } }
    
    public static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    public static func hex(_ h: NSInteger, alpha: CGFloat = 1) -> UIColor {
        return self.rgb(CGFloat(h&0xff0000), CGFloat(h&0x00ff00), CGFloat(h&0x0000ff), alpha: alpha)
    }
}

public enum DeviceType: Int {
    case iPhone4 = 1
    case iPhone5
    case iPhone6
    case iPhonePlus
    case iPhoneX
}

open class Device {
    /// 广告唯一标识IDFA
//    public static var id: String { return ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString }
    // e.g. "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    public static var id: String? { return UIDevice.current.identifierForVendor?.uuidString }
    // e.g. "My iPhone"
    public static var name: String { return UIDevice.current.name }
    // e.g. "iPhone", "iPod touch"
    public static var model: String { return UIDevice.current.model }
    // localized version of model
    public static var localizedModel: String { return UIDevice.current.localizedModel }
    // e.g. "iOS"
    public static var systemName: String { return UIDevice.current.systemName }
    // e.g. "4.0"
    public static var systemVersion: String { return UIDevice.current.systemVersion }
    public static var orientation: UIDeviceOrientation { return UIDevice.current.orientation }
    
    public static let iPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    public static let iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    public static let iPod: Bool = UIDevice.current.model == "iPod touch"
    public static let iPhoneSimulator: Bool = UIDevice.current.model == "iPhone Simulator"
    
    private static func size(_ type: DeviceType) -> Bool {
        if let size = UIScreen.main.currentMode?.size {
            switch type {
            case .iPhone4:
                return CGSize.init(width: 640, height: 960).equalTo(size)
            case .iPhone5:
                return CGSize.init(width: 640, height: 1136).equalTo(size)
            case .iPhone6:
                return CGSize.init(width: 750, height: 1334).equalTo(size)
            case .iPhonePlus:
                return CGSize.init(width: 1242, height: 2208).equalTo(size)
            case .iPhoneX:
                return CGSize.init(width: 1125, height: 2436).equalTo(size)
            }
        } else {
            return false
        }
    }
    
    public static let iPhone4: Bool = Device.size(.iPhone4)
    public static let iPhone5: Bool = Device.size(.iPhone5)
    public static let iPhone6: Bool = Device.size(.iPhone6)
    public static let iPhonePlus: Bool = Device.size(.iPhonePlus)
    public static let iPhoneX: Bool = Device.size(.iPhoneX)
}

open class Screen {
    
    public static func size(_ type: DeviceType) -> CGSize {
        switch type {
        case .iPhone4:
            return CGSize.init(width: 320, height: 480)
        case .iPhone5:
            return CGSize.init(width: 320, height: 568)
        case .iPhone6:
            return CGSize.init(width: 375, height: 667)
        case .iPhonePlus:
            return CGSize.init(width: 414, height: 736)
        case .iPhoneX:
            return CGSize.init(width: 375, height: 812)
        }
    }
    public static let size: CGSize = UIScreen.main.bounds.size
    public static let width: CGFloat = UIScreen.main.bounds.size.width
    public static let height: CGFloat = UIScreen.main.bounds.size.height
    public static let centerX: CGFloat = Screen.width * 0.5
    public static let centerY: CGFloat = Screen.height * 0.5
    public static let statusBarHeight: CGFloat = Device.iPhoneX ? 44 : 20
    public static let navigationBarHeight: CGFloat = 44 + Screen.statusBarHeight
    public static let xBottomMargin: CGFloat = Device.iPhoneX ? 34 : 0
    
    public static let showHeight: CGFloat = Screen.height - Screen.navigationBarHeight - Screen.xBottomMargin
    public static let showXHeight: CGFloat = Screen.height - Screen.navigationBarHeight
    public static let showRect: CGRect = CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.showHeight)
    public static let showXRect: CGRect = CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.showXHeight)
    public static let leftRightMargin: CGFloat = FitXLMS(10, 15, 10, 10)
    public static let topBottomMargin: CGFloat = FitXLMS(15, 20, 15, 15)

    public static var currentController: UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while true {
            if (vc?.isKind(of: UITabBarController.self))! {
                vc = (vc as! UITabBarController).selectedViewController
            } else if (vc?.isKind(of: UINavigationController.self))!{
                vc = (vc as! UINavigationController).visibleViewController
            } else if ((vc?.presentedViewController) != nil){
                vc =  vc?.presentedViewController
            } else {
                return vc!
            }
        }
        return vc!
    }
    
    static func comparePhone6(ascend: Optional<() -> ()>, same: Optional<() -> ()> = nil, descend: Optional<() -> ()>) -> Void {
        if self.width > 375.0 {
            if let block: () -> () = ascend { block() }
        } else if self.width == 375.0 {
            if let block: () -> () = same { block() }
        } else {
            if let block: () -> () = descend { block() }
        }
    }
}

extension UIView {
    public var controller: UIViewController? {
        var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil
        return nil
    }
}
