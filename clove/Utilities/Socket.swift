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
    var jobs: [(() -> Void)] = []
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
            jobs.forEach { $0() }
        }
        socket.on(clientEvent: .disconnect) { data, ack in
        }
        
        socket.on(Constants.Events.Sent.rawValue){ data, ack in
            guard let responseData = data[0] as? NSDictionary else { return }
            let response = Response<DataType.Basic>(responseData)
            if response.code == 200 {
                print("Got success")
            }
        }

        socket.connect()
    }
    
    init() {
        self.restart()
    }
    
    // MARK: - Publish fuctions
    
    func sendMessage(_ message: Message) {
        emit(Constants.Events.Sent.rawValue, [
            "body": message.body,
            "recipient": message.recipient
        ])
    }
    
    func emit(_ event: String, _ data: [String: Any?]) {
        jobs.append {
            self.socket.emit(event, data)
        }
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
