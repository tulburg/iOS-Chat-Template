//
//  TailView.swift
//  clove
//
//  Created by Tolu Oluwagbemi on 07/03/2023.
//

import UIKit

class TailView: BaseView {
    
    override var oH: CGFloat {
        return 30
    }
    
    override var oW: CGFloat {
        return 16
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init(H: CGFloat, W: CGFloat) {
        super.init(H: H, W: W)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: pX(16), y: pY(28)))
        path.addLine(to: CGPoint(x: W, y: pY(0.5)))
        path.addLine(to: .init(x: pX(0), y: pY(19)))
        path.addCurve(to: CGPoint(x: pX(12.5), y: pY(28)), controlPoint1: .init(x: pX(7.97712), y: pY(18.8532)), controlPoint2: .init(x: pX(11.6758), y: pY(24.7031)))
        path.addCurve(to: .init(x: pX(16), y: pY(28)), controlPoint1: .init(x: pX(13), y: pY(30)), controlPoint2: .init(x: pX(16), y: pY(30.3795)))
        
        shapeLayer.fillColor = UIColor.primary.cgColor
        shapeLayer.path = path.cgPath
    }
}


class BaseView: UIView {
    
    var oH: CGFloat {
        return 0
    }
    var oW: CGFloat {
        return 0
    }
    var H: CGFloat = 0
    var W: CGFloat = 0
    let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    required init(H: CGFloat, W: CGFloat) {
        self.H = H
        self.W = W
        super.init(frame: CGRect(x: 0, y: 0, width: W, height: H))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        clipsToBounds = true
        layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = UIColor.brown.cgColor
    }
    
    
    func toPerc(_ value: CGFloat, of: CGFloat) -> CGFloat {
        return (value / of)
    }
    
    func pY(_ value: CGFloat) -> CGFloat {
        return toPerc(value, of: oH) * H
    }
    func pX(_ value: CGFloat) -> CGFloat {
        return toPerc(value, of: oW) * W
    }
}
