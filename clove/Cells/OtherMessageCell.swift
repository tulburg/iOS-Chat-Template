//
//  OwnMessageCell.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class OtherMessageCell: UITableViewCell, MessageCellProtocol {
    
    
    var body: UILabel!
    var container: UIView!
    var time: UIView!
    var timeLabel: UILabel!
    var tail: TailView!
    var showEmoji: Bool!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        body = UILabel("", UIColor.awayMessageText, .systemFont(ofSize: 16))
        body.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        contentView.autoresizingMask = .flexibleHeight
        autoresizingMask = .flexibleHeight
        let frame = contentView.frame
        contentView.bounds = CGRect(x: 0, y: 0, width: 99999.0, height: 99999.0)
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor.awayMessageBackground
        container.addSubviews(views: body)
        container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
        
        time = UIView()
        timeLabel = UILabel("", .init(hex: 0x9D9D9D), .systemFont(ofSize: 12))
        
        showEmoji = reuseIdentifier!.contains("_emoji")
        let showTime = reuseIdentifier!.contains("_time")
        let showTail = reuseIdentifier!.contains("_tail")
        let showStatus = reuseIdentifier!.contains("_status")
        
        if showEmoji {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "V:|-0-[v0]-0-|", views: body)
            container.addConstraints(format: "H:|-4-[v0]-4-|", views: body)
            container.backgroundColor = UIColor.clear
        }else {
            container.backgroundColor = UIColor.awayMessageBackground
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "V:|-8-[v0]-8-|", views: body)
            container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
        }
        
        if showTime {
            contentView.add().vertical(38).view(container).end(0)
            timeLabel.attributedText = NSMutableAttributedString().bold("Today, ", size: 12, weight: .bold).normal("9:13 am")
            time.add().vertical(16).view(timeLabel, 14).end(8)
            time.constrain(type: .horizontalCenter, timeLabel)
            contentView.add().vertical(0).view(time).end(">=\(showStatus ? 8 : 0)")
            contentView.constrain(type: .horizontalFill, time)
        }else {
            contentView.add().vertical(2).view(container).end(showStatus ? 8 : 0)
        }
        contentView.add().horizontal(16).view(container).end(">=\(0.22 * frame.width)")
            
        tail = TailView(H: 32, W: 20, color: UIColor.awayMessageBackground)
        if showTail {
            tail.transform = .init(scaleX: -1, y: 1)
            container.add().horizontal(0).view(tail, 20).end(">=0")
            container.add().vertical(">=0").view(tail, 32).end(-11.5)
        }else {
            tail.isHidden = true
            container.removeConstraints(contentView.constraints.filter { ($0.firstItem as? UIView) == tail })
        }
        
    }

    
    func prepare(message: Message) {
        body.text = message.body
        timeLabel.attributedText = getTime(message)
        if showEmoji {
            if body.text!.count <= 2 {
                body.font = UIFont.systemFont(ofSize: 60)
            } else {
                body.font = UIFont.systemFont(ofSize: 48)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

protocol MessageCellProtocol {
    func prepare(message: Message)
}

extension MessageCellProtocol {
    func getTime(_ message: Message) -> NSAttributedString {
        var head = ""
        if message.sent?.get(.day) == Date().get(.day) {
            head = "Today "
        }else if message.sent?.get(.month) == Date().get(.month) {
            head = (message.sent?.string(with: "EEE d "))!
        }else if message.sent?.get(.year) == Date().get(.year) {
            head = (message.sent?.string(with: "MMM EEE d "))!
        }
        let tail = message.sent?.string(with: "h:mm a").lowercased()
        return NSMutableAttributedString().bold(head, size: 12, weight: .bold).normal(tail!)
    }

}
