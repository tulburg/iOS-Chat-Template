//
//  Protocols.swift
//  Town SQ
//
//  Created by Tolu Oluwagbemi on 04/01/2023.
//  Copyright © 2023 Tolu Oluwagbemi. All rights reserved.
//

import Foundation

protocol SocketDelegate: AnyObject {
    func socket(didReceive event: Constants.Events, data: Response<DataType.Message>)
}

extension SocketDelegate {
    func connect() {}
    func disconnect() {}
    func socket(didMarkUnread broadcast: Response<DataType.Message>){}
}
