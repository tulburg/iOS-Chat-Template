//
//  OwnMessageCell.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class OwnMessageCell: UITableViewCell {
    
    var message: String!
    var feedTime: UILabel!
    var feedBody: UILabel!
    var container: UIView!
    var tailView: TailView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        feedBody = UILabel("", UIColor.white, .systemFont(ofSize: 16))
        feedBody.numberOfLines = 50
        self.backgroundColor = UIColor.clear
        
        container = UIView()
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.backgroundColor = UIColor.primary
        container.addSubviews(views: feedBody)
        container.addConstraints(format: "H:|-12-[v0]-12-|", views: feedBody)
        container.addConstraints(format: "V:|-8-[v0]-8-|", views: feedBody)
        
        contentView.addSubviews(views: container)
        contentView.addConstraints(format: "H:|-(>=68)-[v0]-18-|", views: container)
        contentView.addConstraints(format: "V:|-4-[v0]-(>=0)-|", views: container)
        
        tailView = TailView(H: 32, W: 20)
        contentView.add().horizontal(">=0").view(tailView, 20).end(18.25)
        contentView.add().vertical(">=0").view(tailView, 32).end(-11.5)
        
        tailView.isHidden = true
    }
    
    func prepare(_ message: String) {
        self.message = message
        feedBody.text = message
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
            container.backgroundColor = UIColor.primary
            feedBody.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func expand() {
        contentView.addSubview(feedTime)
        contentView.addConstraints(format: "H:|-(>=0)-[v0]-24-|", views: feedTime)
        contentView.addConstraints(format: "V:|-8-[v0]-4-[v1]-(>=0)-|", views: container, feedTime)
    }
    
    func hideTail() {
        tailView.isHidden = true
    }
    
    func showTail() {
        tailView.isHidden = false
    }
}
