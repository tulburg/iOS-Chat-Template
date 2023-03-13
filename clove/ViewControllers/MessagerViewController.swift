//
//  MessagerViewController.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//


import UIKit
import NotificationCenter

class MessagerViewController: ViewController, SocketDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var tableView: UITableView!
    var messageField: UITextView!
    var messageContainer: UIView!
    var sendButton: UIImageView!
    var tableContainer: UIView!
    
    var messageContainerBottomConstraint: NSLayoutConstraint!
    var messageFieldHeightConstraint: NSLayoutConstraint!
    var messageCellHeightConstraint: NSLayoutConstraint!
    
    var messageFieldHeight: CGFloat = 0
    
    var messages: [Message] = []
    var recipient: String?
    var sender: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let senderId = UserDefaults.standard.string(forKey: "id") {
            sender = senderId
        }
        let map = [
            "adam": "89434-59305-5893-5783",
            "tulburg": "4893-58934-5893-4344"
        ]
        let username = UserDefaults.standard.string(forKey: "username")
        recipient = (map[username!])!
        navigationItem.title = "Broadcast"
        print("sender: \(sender!) && recipient: \(recipient!)")
        if let messages = DB.fetchMessages(recipient: recipient!, sender: sender!) {
            self.messages = messages
        }
        
        self.navigationItem.backBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(20, for: .default)
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.image = UIImage()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: .none)
        
        self.view.backgroundColor = UIColor.background
        
        tableContainer = UIView()
        tableContainer.backgroundColor = UIColor.accent
        
        buildTableView()
        
        buildMessageField()
        
        tableContainer.addSubview(tableView)
        tableContainer.constrain(type: .horizontalFill, tableView)
        tableContainer.addConstraints(format: "V:|-0-[v0]-0-|", views: tableView)
        
        messageContainer = UIView()
        
        let borderBottom = UIView()
        borderBottom.backgroundColor = UIColor.clear // Color.separator
        let buttonImage = UIImage(systemName: "arrow.up.circle.fill")?.withTintColor(UIColor.primary, renderingMode: .alwaysOriginal)
        sendButton = UIImageView(image: buttonImage)
        sendButton.isUserInteractionEnabled = true
        sendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(send)))
        
        let messageWrap = UIView()
        messageWrap.layer.cornerRadius = 20
        messageWrap.backgroundColor = UIColor.darkBackground
        messageWrap.add().horizontal(8).view(messageField).gap(0).view(sendButton, 36).end(4)
        messageWrap.add().vertical(0).view(messageField, ">=35").end(0)
        messageWrap.add().vertical(">=0").view(sendButton, 35).end(2)
        let borderTop = UIView()
        borderTop.backgroundColor = UIColor.separator
        messageContainer.add().vertical(">=0").view(borderTop, 1).gap(6).view(messageWrap, ">=40").end(4)
        messageContainer.constrain(type: .horizontalFill, messageWrap, margin: 16)
        messageContainer.constrain(type: .horizontalFill, borderTop)
        messageContainer.backgroundColor = UIColor.background
        
        view.add().vertical(0).view(tableContainer).gap(0).view(messageContainer, 52).end(safeAreaInset!.bottom)
        view.constrain(type: .horizontalFill, tableContainer, messageContainer)
        
        for c in self.view.constraints where c.firstAttribute == .bottom && c.secondItem as? UIView == messageContainer {
            messageContainerBottomConstraint = c
        }
        
        for c in messageWrap.constraints where c.firstAttribute == .height && c.firstItem as? UIView == messageField {
            messageFieldHeightConstraint = c
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Socket.shared.registerDelegate(self)
        tableView.scrollToRow(at: IndexPath.init(row: messages.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: .none)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: .none)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: .none)
        
        Socket.shared.unregisterDelegate(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    var lastMessage: Message?
    var nextMessage: Message?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if indexPath.row < messages.count - 1 {
            nextMessage = messages[indexPath.row + 1]
        }
        if indexPath.row > 1 {
            lastMessage = messages[indexPath.row - 1]
        }
        var id: String!, showTime = false, showStatus = false, showTail = false
        if message.sender! == recipient {
            id = "other_message_cell"
            
            var backTimeDiff: Double = 0
            var nextTimeDiff: Double = 0
            if lastMessage != nil {
                backTimeDiff = (message.sent?.timeIntervalSince1970)! - (lastMessage?.sent?.timeIntervalSince1970)!
            }
            if nextMessage != nil {
                nextTimeDiff = (nextMessage?.sent?.timeIntervalSince1970)! - (message.sent?.timeIntervalSince1970)!
            }
            if (!(message.body!.containsOnlyEmoji && (message.body?.count)! <= 4))
                && nextTimeDiff > 120 {
                showTail = true
            }
            if (backTimeDiff > 60 * 24) { showTime = true }
            if (nextTimeDiff > 120) { showStatus = true }
            
            
        }else {
            id = "own_message_cell";
            var backTimeDiff: Double = 0
            var nextTimeDiff: Double = 0
            if lastMessage != nil {
                backTimeDiff = (message.sent?.timeIntervalSince1970)! - (lastMessage?.sent?.timeIntervalSince1970)!
            }
            if nextMessage != nil {
                nextTimeDiff = (nextMessage?.sent?.timeIntervalSince1970)! - (message.sent?.timeIntervalSince1970)!
            }
            
            if (nextTimeDiff > 120) { showTail = true }
            if (backTimeDiff > 60 * 24) { showTime = true }
            if (nextTimeDiff > 120) { showStatus = true }
        }
        
        if nextMessage != nil && nextMessage?.sender != message.sender {
            showTail = true
            showStatus = true
        }

        if indexPath.row == messages.count - 1 {
            showTail = true
            showStatus = true
        }
        
        if (message.body!.containsOnlyEmoji && (message.body?.count)! <= 4) {
            id.append("_emoji")
            showTail = false
        }
        
//        if showStatus && nextMessage?.sender == message.sender {
//            showStatus = false
//        }
        
        if indexPath.row == 0 {
            showTime = true
        }
        
        if showTail { id.append("_tail") }
        if showTime { id.append("_time") }
        if showStatus { id.append("_status") }
        
        lastMessage = message
        
        let cell: MessageCellProtocol = (tableView.dequeueReusableCell(withIdentifier: id) as? MessageCellProtocol)!
        cell.prepare(message: message)
        
        return cell as! UITableViewCell
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let kFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if messageContainerBottomConstraint != nil {
                messageContainerBottomConstraint.constant = (kFrame.height + 4)
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                if self.messages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }, completion: { _ in
                
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if messageContainerBottomConstraint != nil {
            messageContainerBottomConstraint.constant = 44
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func send() {
        if let body = messageField.text {
            messageField.resignFirstResponder()
            messageField.text = ""
            messageFieldHeightConstraint.constant = 40
            self.view.constraints.forEach({ constraint in
                if constraint.firstAttribute == .height && (constraint.firstItem as? UIView) == messageContainer {
                    constraint.constant = 40 + 12
                }
            })
            
            let message = Message(context: DB.shared.context)
            message.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
            message.sent = Date()
            message.sender = sender
            message.recipient = recipient
            DB.shared.save()
            messages.append(message)
            Socket.shared.sendMessage(message)
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [self] in
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
            })
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            self.view.constraints.forEach({ constraint in
                if constraint.firstAttribute == .height && (constraint.firstItem as? UIView) == messageContainer {
                    constraint.constant = 40 + 12
                }
            })
            messageFieldHeightConstraint.constant = 40
            self.messageField.superview?.layoutIfNeeded()
            return
        }
        
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if textView.contentSize.height > 116 {
            textView.isScrollEnabled = true
        }
        else { textView.isScrollEnabled = false }
        if estimatedSize.height < 52 { return }
        self.view.constraints.forEach({ constraint in
            if constraint.firstAttribute == .height && (constraint.firstItem as? UIView) == messageContainer {
                constraint.constant = min(estimatedSize.height, 116) + 12
            }
        })
        if self.messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
        }
        messageFieldHeightConstraint.constant = min(estimatedSize.height, 116)
        self.messageField.superview?.layoutIfNeeded()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        NotificationCenter.default.post(Notification(name: Notification.Name("UITextViewTextDidChangeSelection"), object: textView))
    }
    
    // MARK: - Build functions
    
    func buildTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.background
        tableView.keyboardDismissMode = .onDrag
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_tail")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_tail_time")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_tail_status")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_tail_time_status")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_time")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_time_status")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_status")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_emoji")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_emoji_time")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_emoji_time_status")
        tableView.register(OwnMessageCell.self, forCellReuseIdentifier: "own_message_cell_emoji_status")
        
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_tail")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_tail_time")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_tail_status")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_tail_time_status")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_time")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_time_status")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_status")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_emoji")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_emoji_time")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_emoji_time_status")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "other_message_cell_emoji_status")
        
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }
    
    func buildMessageField() {
        messageField = UITextView()
        messageField.backgroundColor = UIColor.clear
        messageField.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 2)
        messageField.font = UIFont.systemFont(ofSize: 18)
        messageField.delegate = self
        messageField.placeholder = "Message here"
        messageField.textAlignment = .natural
        messageField.showsVerticalScrollIndicator = false
    }
    
    
    // MARK: - Socket handlers
    
    func connect() {}
    
    func disconnect() {}
    
    func socket(didMarkUnread broadcast: Response<DataType.Message>) {}
    
    func socket(didReceive event: Constants.Events, data: Response<DataType.Message>) {
        if let messages = DB.fetchMessages(recipient: recipient!, sender: sender!) {
            self.messages = messages
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(item: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func socket(didReceiveStatus message: Message) {
        tableView.reloadData()
    }
}
