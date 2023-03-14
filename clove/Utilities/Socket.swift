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
            let pendingEvents: [Event] = DB.shared.find(.Event, predicate: nil) as! [Event]
            print("Reconnected! Retrying pendings...\(pendingEvents.count) pending")
            pendingEvents.forEach { event in
                if event.name != nil {
                    print("Retrying for item at \(event.name!):: \(event.id!)")
                    socket.emit(event.name!, (event.data?.data(using: .utf8)?.json())!)
                    if event.name!.contains("receipt") {
                        DB.shared.delete(.Event, predicate: NSPredicate(format: "id = %@", event.id!))
                    }
                }
            }
            print("Queue reset!")
        }
        socket.on(clientEvent: .disconnect) { data, ack in
        }
        
        socket.on(Constants.Events.Sent.rawValue){ data, ack in
            print("Socket :: Message sent")
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Sent>(responseData)
            if response.code == 200 {
                let itemKey = (response.data?.sent?.toString())!
                self.removeEvent(id: itemKey)
                let data = [
                    "id": (response.data?.id)!
                ]
                let eventKey = "\((response.data?.id)!)::Sent"
                self.emit(Constants.Events.Sent.receipt(), data)
                self.registerEvent(Constants.Events.Sent.receipt(), eventKey, data)
                
                
                let messages = DB.shared.find(.Message, predicate: NSPredicate(format: "tmpid = %@", (response.data?.tmpid)! as CVarArg)) as! [Message]
                if messages.count > 0 {
                    let message = messages[0]
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
                
            }
        }
        
        socket.on(Constants.Events.Sent.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Sent>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Sent"
                self.removeEvent(id: itemKey)
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
                let itemKey = "\((response.data?.id)!)::Received"
                let data = [
                    "sender": (response.data?.sender)!,
                    "id": (response.data?.id)!
                ]
                
                self.emit(Constants.Events.Message.receipt(), data)
                self.registerEvent(Constants.Events.Message.receipt(), itemKey, data)
                
                self.delegates.forEach{ $0.socket(didReceive: .Message, data: response) }
            }
        }
        
        socket.on(Constants.Events.Message.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Message>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Received"
                self.removeEvent(id: itemKey)
            }
        }
        
        socket.on(Constants.Events.Delivered.rawValue) { data, ack in
            print("Socket :: Message Delivered")
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Delivered>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Delivered"
                let data = [
                    "id": (response.data?.id)!
                ]
                self.emit(Constants.Events.Delivered.receipt(), data)
                self.registerEvent(Constants.Events.Delivered.receipt(), itemKey, data)
                
                if let item: Message = DB.shared.findById(.Message, id: (response.data?.id)!) as? Message {
                    item.status = Constants.Status.Delivered.rawValue
                    DB.shared.save()
                    self.delegates.forEach{ $0.socket(didReceiveStatus: item) }
                }
            }
        }
        
        socket.on(Constants.Events.Delivered.receipt()) { data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Message>(responseData)
            if response.code == 200 {
                let itemKey = "\((response.data?.id)!)::Delivered"
                self.removeEvent(id: itemKey)
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
        let tmpid = UUID()
        let data = [
            "sent": message.sent?.toString(),
            "body": message.body,
            "recipient": message.recipient,
            "tmpid": tmpid.uuidString
        ]
        message.tmpid = tmpid
        DB.shared.save()
        registerEvent(Constants.Events.Sent.rawValue, (message.sent?.toString())!, data)
        self.emit(Constants.Events.Sent.rawValue, data)
    }
    
    private func registerEvent(_ name: String, _ id: String, _ data: [String: String?]) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        DB.addEvent(name, id: id, data: String(data: encoded, encoding: .utf8)!)
    }
    
    private func removeEvent(id: String) {
        DB.shared.delete(.Event, predicate: NSPredicate(format: "id = %@", id as CVarArg))
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
