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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        body = UILabel("", UIColor.awayMessageText, .systemFont(ofSize: 16))
        body.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        contentView.autoresizingMask = .flexibleHeight
        autoresizingMask = .flexibleHeight
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor.awayMessageBackground
        container.addSubviews(views: body)
        container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
        container.addConstraints(format: "V:|-8-[v0]-8-|", views: body)
        
        time = UIView()
        timeLabel = UILabel("", .init(hex: 0x9D9D9D), .systemFont(ofSize: 12))
        timeLabel.attributedText = NSMutableAttributedString().bold("Today, ", size: 12, weight: .bold).normal("9:13 am")
        time.add().vertical(12).view(timeLabel, 14).end(12)
        time.constrain(type: .horizontalCenter, timeLabel)
        
        contentView.bounds = CGRect(x: 0, y: 0, width: 99999.0, height: 99999.0)
        contentView.add().vertical(4).view(container).end(0)
        contentView.add().vertical(0).view(time).end(">=0")
        contentView.add().horizontal(18).view(container).end(">=68")
        contentView.constrain(type: .horizontalFill, time)
        
        tail = TailView(H: 32, W: 20, color: UIColor.awayMessageBackground)
        tail.transform = .init(scaleX: -1, y: 1)
        contentView.add().horizontal(18).view(tail, 20).end(">=0")
        contentView.add().vertical(">=0").view(tail, 32).end(-11.5)
        tail.isHidden = true
        
    }
    
    func toggleTime(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.2, animations: {
                self.time.isHidden = false
            })
            for c in contentView.constraints where (c.firstItem as? UIView) == container && c.firstAttribute == .top {
                c.constant = 42
            }
        }else {
            UIView.animate(withDuration: 0.2, animations: {
                self.time.isHidden = true
            })
            for c in contentView.constraints where (c.firstItem as? UIView) == container && c.firstAttribute == .top {
                c.constant = 4
            }
        }
        setNeedsUpdateConstraints()
    }
    
    func toggleTail(show: Bool) {
        if show {
            tail.isHidden = false
        }else {
            tail.isHidden = true
        }
    }
    
    func toggleStatus(show: Bool) {}
    
    func prepare(message: Message) {
        body.text = message.body
        timeLabel.text = message.sent?.string(with: "hh:mm a").lowercased()
        emojiCheck()
    }
    
    func prepareForQuestion(_ body: String) {
        self.body.text = body
        emojiCheck()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func emojiCheck() {
        if (body.text?.containsOnlyEmoji)! && (body.text?.count)! <= 4 {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "H:|-0-[v0]-0-|", views: body)
            container.addConstraints(format: "V:|-0-[v0]-0-|", views: body)
            container.layoutIfNeeded()
            if body.text!.count <= 2 {
                body.font = UIFont.systemFont(ofSize: 60)
            } else {
                body.font = UIFont.systemFont(ofSize: 48)
            }
            container.backgroundColor = UIColor.clear
        } else {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
            container.addConstraints(format: "V:|-8-[v0]-8-|", views: body)
            container.layoutIfNeeded()
            body.font = UIFont.systemFont(ofSize: 16)
            container.backgroundColor = UIColor.awayMessageBackground
        }
    }
    
}

protocol MessageCellProtocol {
    func toggleTime(show: Bool)
    func toggleTail(show: Bool)
    func toggleStatus(show: Bool)
    func prepare(message: Message)
}
