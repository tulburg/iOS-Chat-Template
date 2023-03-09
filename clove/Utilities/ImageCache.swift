//
//  ImageCache.swift
//  Kast
//
//  Created by Tolu Oluwagbemi on 19/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//

import Foundation
import CryptoKit

class ImageCache {
    
    private static var instance: ImageCache = {
        return ImageCache(pathName: "photo-cache")
    }()
    
    var pathName: String!
    var rootDir: URL!
    private var list: [URL]!
    
    init(pathName: String) {
        self.pathName = pathName
        guard let documentsDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        let manager = FileManager.default;
        rootDir = documentsDirectoryURL.appendingPathExtension(pathName)
        do {
            try manager.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)
            list = try manager.contentsOfDirectory(at: rootDir, includingPropertiesForKeys: nil)
        }catch let e {
            print(e)
        }
    }
    
    func drop() {
        let manager = FileManager.default;
        do {
            let items = try manager.contentsOfDirectory(at: rootDir, includingPropertiesForKeys: nil)
            try items.forEach({ item in
                print("Clearning Cache :: " + item.absoluteString)
                try manager.removeItem(at: item.absoluteURL)
            })
        }catch let e {
            print(e)
        }
    }
    
    func set(data: Data, path: String, completion: ((_ path: String) -> Void)?) {
        set(data: data, url: URL(string: path)!, completion: completion)
    }
    
    func set(data: Data, url: URL, completion: ((_ path: String) -> Void)?) {
        let name = MD5(string: url.absoluteString)
        do {
            let path = URL(string: rootDir.absoluteString + "\(name).jpg")
            try data.write(to: path!, options: .withoutOverwriting)
            if completion != nil { completion!(path!.absoluteString) }
        }catch {}
    }
    
    func fetch(url: URL) -> String? {
        let name = MD5(string: url.absoluteString)
        let addr = URL(string: rootDir.absoluteString + "\(name).jpg")
        if let index = list.lastIndex(where: { baseUrl in
            return baseUrl.pathComponents.last == addr?.pathComponents.last
        }) {
            return list[index].path
        }
        return nil
    }
    
    class func shared() -> ImageCache {
        return instance
    }
}



func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
    
    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}
