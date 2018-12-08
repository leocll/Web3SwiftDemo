//
//  IPFS.swift
//  Web3SwiftDemo
//
//  Created by admin on 2018/11/1.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import Ipfs
import Moya //pod 'Moya/RxSwift'
import RxSwift
import ObjectMapper

extension UIImageView {
    // 图片
    func setImage(withIpfsHash: String?, placeholderImage: UIImage? = UIImage.placeholder) {
        self.image = placeholderImage
        guard let hash = withIpfsHash else {
            return
        }
        PPS_ipfs.catImage(hash) { [weak self] (image, res, err) in
            DispatchQueue.main.async {
                self?.image = image ?? placeholderImage
            }
        }
    }
}

class PPS_ipfsModel: Mappable {
    var ipfsHash_source: String?
    var isEmpty: Bool {
        return self.ipfsHash_source?.isEmpty ?? true
    }
    
    init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {}
}

class PPS_ipfs {
    // 缓存
    private static var ipfsCache: [String: Data] = [String: Data]()
    private static var ipfsImageCache: [String: UIImage] = [String: UIImage]()
    private static let ipfsUserDefaults: UserDefaults! = UserDefaults.init(suiteName: "ipfsData")
    private static func cacheData(_ data: Data, forHash: String) {
        ipfsCache[forHash] = data
        ipfsUserDefaults.setValue(data, forKey: forHash)
        ipfsUserDefaults.synchronize()
    }
    private static func data(forHash: String) -> Data? {
        if let data = ipfsCache[forHash] { return data }
        return ipfsUserDefaults.value(forKey: forHash) as? Data
    }
    private static func cacheImage(_ image: UIImage, forHash: String) {
        ipfsImageCache[forHash] = image
    }
    private static func image(forHash: String) -> UIImage? {
        return ipfsImageCache[forHash]
    }
    static func clearCache() {
        ipfsCache.removeAll()
        ipfsImageCache.removeAll()
        let dics = ipfsUserDefaults.dictionaryRepresentation()
        for key in dics {
            ipfsUserDefaults.removeObject(forKey: key.key)
        }
        ipfsUserDefaults.synchronize()
    }
    
    // 添加数据
    static func addImage(_ image: UIImage, complete:((String?, Error?)->Void)?) {
        var data: Data? = image.pngData()
        if data == nil { data = image.jpegData(compressionQuality: 1) }
        if data == nil {
            complete?(nil, NSError.init(domain: "image -> data is nil", code: 0, userInfo: nil))
            return
        }
        self.add(data!) { (ipfsHash, error) in
            if let hash = ipfsHash { self.cacheImage(image, forHash: hash) }
            complete?(ipfsHash, error)
        }
        self.add(data!, complete: complete)
    }
    
    static func addDict(_ dict: [String: Any], complete:((String?, Error?)->Void)?) {
        let data: Data? = dict.jsonData
        if data == nil {
            complete?(nil, NSError.init(domain: "dict -> data is nil", code: 0, userInfo: nil))
            return
        }
        self.add(data!, complete: complete)
    }
    
    static func add(_ data: Data, complete:((String?, Error?)->Void)?) {
        Ipfs.files.add(data: data) { (result) in
            switch result {
            case let .success(moyaResponse):
                print("statusCode: \(moyaResponse.statusCode)")
                print("result: \(moyaResponse.data)")
                
                let object = try? moyaResponse.map(ObjectModel.self)
                // 缓存
                if let hash = object?.hash { self.cacheData(data, forHash: hash) }
                complete?(object?.hash, nil)
                break
            case let .failure(error):
                print("failure: \(error.localizedDescription)")
                complete?(nil, error)
                break
            }
        }
    }
    
    // 查询数据
    static func catImage(_ path: String, complete: ((UIImage?,Moya.Response?,Error?) -> Void)?) {
        if let image = self.image(forHash: path) {
            complete?(image,nil,nil)
            return
        }
        self.cat(path) { (res, err) in
            var image: UIImage? = nil
            if let data = res?.data { image = UIImage.init(data: data) }
            if image != nil { self.cacheImage(image!, forHash: path) }
            complete?(image,res,err)
        }
    }
    
    static func catModels<T: PPS_ipfsModel>(paths: [String], type: T.Type, callbackQueue: DispatchQueue = DispatchQueue.main, complete:(([T]?,[Moya.Response]?,Error?) -> Void)?) {
        var models: [T] = [T]()
        self.cat(paths: paths, callbackQueue: callbackQueue, once: { (path, moyaResponse, error) in
            if let data = moyaResponse?.data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    if let model = type.init(JSON:(json as! [String: Any])) {
                        model.ipfsHash_source = path
                        models.append(model)
                    }
                }
            }
        }) { (res, err) in
            complete?(models.isEmpty ? nil : models, res, err)
        }
    }
    
    static func cat(paths: [String], callbackQueue: DispatchQueue = DispatchQueue.main, once:((String,Moya.Response?,Error?) -> Void)? = nil, complete:(([Moya.Response]?,Error?) -> Void)?) {
        if paths.isEmpty {
            complete?(nil,NSError.init(domain: "count of paths is zero", code: 0, userInfo: nil))
            return
        }
        
        var res = [Moya.Response]()
        var err: Error? = nil
        
        let group = DispatchGroup()
        
        for path in paths {
            group.enter()
            self.cat(path, callbackQueue: callbackQueue, complete: { (response, error) in
                if response != nil { res.append(response!)}
                once?(path, response, error)
                err = error
                
                group.leave()
            })
        }
        group.notify(queue: callbackQueue) {
            complete?(res.isEmpty ? nil : res, err)
        }
    }
    
    static func catModel<T: PPS_ipfsModel>(_ path: String, type: T.Type, callbackQueue: DispatchQueue = DispatchQueue.main, complete:(((T?,Moya.Response?,Error?) -> Void)?)) {
        self.cat(path) { (moyaResponse, error) in
            var model: T? = nil
            if let data = moyaResponse?.data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    model = type.init(JSON:(json as! [String: Any]))
                    model?.ipfsHash_source = path
                }
            }
            complete?(model,moyaResponse,error)
        }
    }
    
    static func cat(_ path: String, callbackQueue: DispatchQueue = DispatchQueue.main, complete:(((Moya.Response?,Error?) -> Void)?)) {
        if let data = self.data(forHash: path) {
            callbackQueue.async {
                complete?(Moya.Response.init(statusCode: 100, data: data),nil)
            }
            return
        }
        Ipfs.files.cat(ipfsPath: path, callbackQueue: callbackQueue) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                print("statusCode: \(statusCode)")
                print("result: \(data)")
                // 缓存
                if !data.isEmpty { self.cacheData(data, forHash: path) }
                complete?(moyaResponse,nil)
                break
            case let .failure(error):
                print("failure: \(error.localizedDescription)")
                complete?(nil,error)
                break
            }
        }
    }
}
