//
//  OwnMessageCell.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class OtherMessageCell: UITableViewCell {
    
    var message: String = "This is not something i thought i will see today, i know i can’t escape, nothing good happens after two, its true. My bad habits leads to you"
    var feedTime: UILabel!
    var feedBody: UILabel!
    var container: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        feedBody = UILabel(message, UIColor(hex: 0x323232), .systemFont(ofSize: 16))
        feedBody.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor(hex: 0xf1f1f1)
        container.addSubviews(views: feedBody)
        container.addConstraints(format: "H:|-12-[v0]-12-|", views: feedBody)
        container.addConstraints(format: "V:|-8-[v0]-8-|", views: feedBody)
        
        contentView.addSubviews(views: container)
        contentView.addConstraints(format: "H:|-18-[v0]-(>=60)-|", views: container)
        contentView.addConstraints(format: "V:|-4-[v0]-(>=0)-|", views: container)
    }
    
    func prepare(_ message: String) {
        self.message = message
        feedBody.text = message
        emojiCheck()
    }
    
    func prepareForQuestion(_ body: String) {
        feedBody.text = body
        emojiCheck()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func emojiCheck() {
        if (feedBody.text?.containsOnlyEmoji)! && (feedBody.text?.count)! <= 4 {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "H:|-0-[v0]-0-|", views: feedBody)
            container.addConstraints(format: "V:|-0-[v0]-0-|", views: feedBody)
            container.layoutIfNeeded()
            if feedBody.text!.count <= 2 {
                feedBody.font = UIFont.systemFont(ofSize: 60)
            } else {
                feedBody.font = UIFont.systemFont(ofSize: 48)
            }
            
            container.backgroundColor = UIColor.clear
        } else {
            container.removeConstraints(container.constraints)
            container.addConstraints(format: "H:|-12-[v0]-12-|", views: feedBody)
            container.addConstraints(format: "V:|-8-[v0]-8-|", views: feedBody)
            container.layoutIfNeeded()
            container.backgroundColor = UIColor.create(0xf1f1f1, dark: 0x242424)
            feedBody.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    func fold() {
    }
    
    func expand() {
        feedTime = UILabel("2d ago", UIColor.accent, UIFont.italicSystemFont(ofSize: 12))
        contentView.addSubview(feedTime)
        contentView.addConstraints(format: "H:|-24-[v0]-(>=0)-|", views: feedTime)
        contentView.addConstraints(format: "V:|-8-[v0]-4-[v1]-(>=0)-|", views: container, feedTime)
    }
    
}
