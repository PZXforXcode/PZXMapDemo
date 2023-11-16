//
//  UIView+Function.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2020/12/4.
//

import Foundation
import SnapKit

// FIXME: - 便利构造方法
extension UIView {
    convenience init(superView: UIView? = nil, backgroundColor: UIColor? = UIColor.clear, closure: ((SnapKit.ConstraintMaker) -> Void)? = nil) {
        self.init()
        self.backgroundColor = backgroundColor
        superView?.addSubview(self)
        if let closure = closure {
            self.snp.makeConstraints(closure)
        }
    }
    
    //生成虚线
    func drawDashLine(_ lineView:UIView,strokeColor: UIColor, lineWidth: CGFloat = 1, lineLength: Int = 10, lineSpacing: Int = 5) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = lineView.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        
        //每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
//        let y = lineView.layer.bounds.height - lineWidth
        let x = lineView.layer.bounds.width - lineWidth
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: lineView.layer.bounds.height))
        shapeLayer.path = path
        lineView.layer.addSublayer(shapeLayer)
    }
    
    
}
