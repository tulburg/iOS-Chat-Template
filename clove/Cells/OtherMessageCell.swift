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
    var image: UIImageView!
    var timeIndicator: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        body = UILabel("", UIColor.awayMessageText, .systemFont(ofSize: 16))
        body.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        contentView.autoresizingMask = .flexibleHeight
        autoresizingMask = .flexibleHeight
        let frame = contentView.frame
        contentView.bounds = CGRect(x: 0, y: 0, width: 99999.0, height: 99999.0)
        image = UIImageView()
        image.layer.cornerRadius = 16
        image.clipsToBounds = true
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor.awayMessageBackground
        container.addSubviews(views: body)
        container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
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
            container.addConstraints(format: "H:|-0-[v0]-0-|", views: body)
            container.backgroundColor = UIColor.clear
        }else {
            container.backgroundColor = UIColor.awayMessageBackground
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "V:|-8-[v0]-8-|", views: body)
            container.addConstraints(format: "H:|-12-[v0]-12-|", views: body)
        }
        
        if showTime {
            contentView.add().vertical(38).view(container).end(">=\(showStatus ? 16 : 0)")
            timeLabel.attributedText = NSMutableAttributedString().bold("Today, ", size: 12, weight: .bold).normal("9:13 am")
            time.add().vertical(16).view(timeLabel, 14).end(8)
            time.constrain(type: .horizontalCenter, timeLabel)
            contentView.add().vertical(0).view(time).end(">=\(showStatus ? 16 : 0)")
            contentView.constrain(type: .horizontalFill, time)
        }else {
            contentView.add().vertical(2).view(container).end(showStatus ? 16 : 0)
        }
        
        contentView.add().view(container).view(timeIndicator).end(">=0")
        container.centerYAnchor.constraint(equalTo: timeIndicator.centerYAnchor).isActive = true
        
        contentView.add().horizontal(16).view(image, 32).gap(12).view(container).end(">=\(0.25 * frame.width)")
        contentView.add().vertical(">=0").view(image, 32).end(12)
            
        tail = TailView(H: 32, W: 20, color: UIColor.awayMessageBackground)
        if showTail {
            tail.transform = .init(scaleX: -1, y: 1)
            container.add().horizontal(0).view(tail, 20).end(">=0")
            container.add().vertical(">=0").view(tail, 32).end(-11.5)
            image.isHidden = false
        }else {
            tail.isHidden = true
            container.removeConstraints(contentView.constraints.filter { ($0.firstItem as? UIView) == tail })
            image.isHidden = true
        }
    }

    
    func prepare(message: Message) {
        body.text = message.body
        timeLabel.attributedText = getTime(message)
        timeIndicator.text = getMiniTime(message)
        let imageUrl = [
            "89434-59305-5893-5783": "https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=360",
            "4893-58934-5893-4344": "https://www.microsoft.com/en-us/research/uploads/prod/2022/10/adam-square.jpg"
        ]
        image.download(link: imageUrl[message.recipient!]!, contentMode: .scaleAspectFill)
        if showEmoji {
            if body.text!.count <= 2 {
                body.font = UIFont.systemFont(ofSize: 60)
            } else {
                body.font = UIFont.systemFont(ofSize: 48)
            }
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
    
    func getMiniTime(_ message: Message) -> String {
        return (message.sent?.string(with: "h:mm a").lowercased())!
    }

}
