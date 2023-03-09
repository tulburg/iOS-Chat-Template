//
//  Objects.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 21/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//
import Foundation

class Response<T: ResponseProtocol> {
    var code: Int?
    var status: Int?
    var message: String?
    var error: String?
    var data: T?
    
    init(_ dict: NSDictionary) {
        code = dict.int("code")
        status = dict.int("status")
        message = dict.string("message")
        data = dict.type("data")
        error = dict.string("error")
    }
}

class DataType {
    class Basic: ResponseProtocol {
        required init(_ value: String) {}
    }
    class Sent: ResponseProtocol {
        var id: String?
        var sent: Date?
        required init(_ dict: NSDictionary) {
            id = dict.string("id")
            sent = dict.date("sent")
        }
    }
    class Message: ResponseProtocol {
        var id: String?
        var recipient: String?
        var sender: String?
        var body: String?
        var sent: Date?
        required init(_ dict: NSDictionary) {
            id = dict.string("id")
            recipient = dict.string("recipient")
            sender = dict.string("sender")
            body = dict.string("body")
            sent = dict.date("sent")
        }
    }
}


fileprivate extension NSDictionary {
    func string(_ key: String) -> String? {
        if let value = self[key] as? String {
            return value
        }
        return nil
    }
    
    func date(_ key: String) -> Date? {
        if let value = self[key] as? String {
            return Date.from(string: value)
        }
        return nil
    }
    
    func int(_ key: String) -> Int? {
        if let value = self[key] as? Int {
            return value
        }
        return nil
    }
    
    func type<T: ResponseProtocol>(_ key: String) -> T? {
        if let value = self[key] as? NSDictionary {
            return T.init(value)
        }
        if let stringValue = self[key] as? String {
            return T.init(stringValue)
        }
        return nil
    }
}

@objc protocol ResponseProtocol {
    init(_ dict: NSDictionary)
    init(_ value: String)
}
