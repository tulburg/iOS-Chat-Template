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
                self.queue.removeObject(forKey: (response.data?.sent?.toString())!)
                print((response.data?.sent?.toString())!, self.queue.allKeys)
                print("Socket :: Removing from queue, left \(self.queue.count)")
                self.emit(Constants.Events.Sent.receipt(), [
                    "id": (response.data?.id)!
                ])
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
