//
//  Socket.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 30/12/2022.
//  Copyright © 2022 Tolu Oluwagbemi. All rights reserved.
//

import Foundation
import SocketIO
import CoreData

class Socket {
    
    var socket: SocketIOClient!
    var queue: NSMutableDictionary = [:]
    var messageQueue: NSMutableDictionary = [:]
    var delegates: [SocketDelegate] = []
    
    static let shared: Socket = {
        return Socket()
    }()
    
    func restart () {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.makeSocket()
        self.socket = delegate.socket
        socket.onAny({ socket in
            print(socket)
        })
        
        socket.on(clientEvent: .connect) { [self] data, ack in
            socket.emit("login", [
                "date": "27-12-1980"
            ])
            print("Reconnected! Retrying pendings...\(queue.count) pending")
            self.queue.forEach {
                print("Retrying for item at \($0.key)")
                (($0.value as? (() -> Void))!)()
            }
            print("Queue reset!")
            self.queue = [:]
        }
        socket.on(clientEvent: .disconnect) { data, ack in
        }
        
        socket.on(Constants.Events.Sent.rawValue){ data, ack in
            print("Socket :: Message sent")
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Sent>(responseData)
            if response.code == 200 {
                let itemKey = (response.data?.sent?.toString())!
                self.queue.removeObject(forKey: itemKey)
                print("Socket :: Removing from queue, left \(self.queue.count)")
                let fn = {
                    self.emit(Constants.Events.Sent.receipt(), [
                        "id": (response.data?.id)!
                    ])
                }
                if let message: Message = self.messageQueue.value(forKey: itemKey) as? Message {
                    message.id = (response.data?.id)!
                    message.status = Constants.Status.Sent.rawValue
                    DB.shared.save()
                    self.delegates.forEach{
                        $0.socket(didReceiveStatus: message)
                    }
                }else {
                    print("Socket :: Error while updating message status")
                    print(responseData)
                }
                self.queue.setValue({ fn() }, forKey:  "\((response.data?.id)!)::Sent")
                fn()
            }
        }
        
        socket.on(Constants.Events.Sent.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Sent>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Sent"
                self.queue.removeObject(forKey: itemKey)
            }
        }
        
        socket.on(Constants.Events.Message.rawValue) { data, ack in
            print("Socket :: Message Received")
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Message>(responseData)
            if response.code == 200 {
                let message = Message(context: DB.shared.context)
                message.sent = response.data?.sent
                message.id = response.data?.id
                message.recipient = response.data?.recipient
                message.body = response.data?.body
                message.sender = response.data?.sender
                DB.shared.save()
                let fn = {
                    self.emit(Constants.Events.Message.receipt(), [
                        "sender": (response.data?.sender)!,
                        "id": (response.data?.id)!
                    ])
                }
                self.queue.setValue({ fn() }, forKey: "\((response.data?.id)!)::Received")
                fn()
                self.delegates.forEach{ $0.socket(didReceive: .Message, data: response) }
            }
        }
        
        socket.on(Constants.Events.Message.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Message>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Received"
                self.queue.removeObject(forKey: itemKey)
            }
        }
        
        socket.on(Constants.Events.Delivered.rawValue) { data, ack in
            print("Socket :: Message Delivered")
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Delivered>(responseData)
            if response.code == 200 {
                let fn = {
                    self.emit(Constants.Events.Delivered.receipt(), [
                        "id": (response.data?.id)!
                    ])
                }
                if let item: Message = DB.shared.findById(.Message, id: (response.data?.id)!) as? Message {
                    item.status = Constants.Status.Delivered.rawValue
                    DB.shared.save()
                    self.delegates.forEach{ $0.socket(didReceiveStatus: item) }
                }
                self.queue.setValue({ fn() }, forKey: "\((response.data?.id)!)::Delivered")
                fn()
            }
        }
        
        socket.on(Constants.Events.Delivered.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Message>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Delivered"
                self.queue.removeObject(forKey: itemKey)
            }
        }

        socket.connect()
    }
    
    init() {
        self.restart()
    }
    
    // MARK: - Publish fuctions
    
    func sendMessage(_ message: Message) {
        print("Socket :: Sending message...")
        let fn = { self.emit(Constants.Events.Sent.rawValue, [
            "sent": message.sent?.toString(),
            "body": message.body,
            "recipient": message.recipient
        ]) }
        messageQueue.setValue(message, forKey: (message.sent?.toString())!)
        queue.setValue({ fn() }, forKey: (message.sent?.toString())!)
        fn()
    }
    
    func emit(_ event: String, _ data: [String: Any?]) {
        socket.emit(event, data)
        if socket.status != .connected {
            print("Socket not connected! Retrying...")
        }
    }
    
    func registerDelegate(_ delegate: SocketDelegate) {
        delegates.append(delegate)
    }
    
    func unregisterDelegate(_ delegate: SocketDelegate) {
        delegates.removeAll(where: { return $0 === delegate })
    }
}

enum MediaType: String {
    case photo, video, photos
}
