//
//  OwnMessageCell.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class OwnMessageCell: UITableViewCell, MessageCellProtocol {
    
    var time: UIView!
    var timeLabel: UILabel!
    var body: UILabel!
    var container: UIView!
    var tail: TailView!
    var status: UILabel!
    var showEmoji: Bool!
    var timeIndicator: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        body = UILabel("", UIColor.white, .systemFont(ofSize: 16))
        body.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        contentView.autoresizingMask = .flexibleHeight
        autoresizingMask = .flexibleHeight
        let frame = contentView.frame
        contentView.bounds = CGRect(x: 0, y: 0, width: 99999.0, height: 99999.0)
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor.primary
        container.addSubviews(views: body)
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTime)))
        
        time = UIView()
        timeLabel = UILabel("", .init(hex: 0x9D9D9D), .systemFont(ofSize: 12))
        
        timeIndicator = UILabel("", .init(hex: 0x9D9D9D), .systemFont(ofSize: 12))
        timeIndicator.isHidden = true
        
        showEmoji = reuseIdentifier!.contains("_emoji")
        let showTime = reuseIdentifier!.contains("_time")
        let showTail = reuseIdentifier!.contains("_tail")
        let showStatus = reuseIdentifier!.contains("_status")
        
        if showEmoji {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "V:|-0-[v0]-0-|", views: body)
            container.addConstraints(format: "H:|-(>=4)-[v0]-4-|", views: body)
            container.backgroundColor = UIColor.clear
        }else {
            body.font = UIFont.systemFont(ofSize: 16)
            container.backgroundColor = .primary
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "V:|-8-[v0]-8-|", views: body)
            container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
        }
        
        status = UILabel("Sent!", .init(hex: 0x9d9d9d), .systemFont(ofSize: 12, weight: .regular))
        
        if showStatus {
            contentView.add().horizontal(">=0").view(status).end(28)
            contentView.add().vertical(">=0").view(status).end(16)
        }
        
        if showTime {
            contentView.add().vertical(38).view(container).end(">=\(showStatus ? 32 : 0)")
            timeLabel.attributedText = NSMutableAttributedString().bold("Today, ", size: 12, weight: .bold).normal("9:13 am")
            time.add().vertical(16).view(timeLabel, 14).end(8)
            time.constrain(type: .horizontalCenter, timeLabel)
            
            contentView.add().vertical(0).view(time).end(">=\(showStatus ? 32 : 0)")
            contentView.constrain(type: .horizontalFill, time)
        }else {
            contentView.add().vertical(2).view(container).end(showStatus ? 32 : 0)
        }
        contentView.add().horizontal(">=\(0.25 * frame.width)").view(container).end(16)
        
        contentView.add().view(timeIndicator).view(container).end(16)
        container.centerYAnchor.constraint(equalTo: timeIndicator.centerYAnchor).isActive = true
        
        tail = TailView(H: 32, W: 20, color: UIColor.primary)
        
        if showEmoji {
            status.isHidden = true
        }else {
            status.isHidden = false
        }
        
        if showTail {
            container.add().horizontal(">=0").view(tail, 20).end(0)
            container.add().vertical(">=0").view(tail, 32).end(-11.5)
        }else {
            tail.isHidden = true
            container.removeConstraints(contentView.constraints.filter { ($0.firstItem as? UIView) == tail })
        }
        
    }
    
    func prepare(message: Message) {
        body.text = message.body
        timeLabel.attributedText = getTime(message)
        timeIndicator.text = getMiniTime(message)
        if showEmoji {
            if body.text!.count <= 2 {
                body.font = UIFont.systemFont(ofSize: 60)
            } else {
                body.font = UIFont.systemFont(ofSize: 48)
            }
        }
        if let statusText = message.status {
            status.text = statusText
        }else {
            status.text = "Sending..."
        }
    }
    
    @objc func showTime() {
        timeIndicator.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.timeIndicator.isHidden = true
        })
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
