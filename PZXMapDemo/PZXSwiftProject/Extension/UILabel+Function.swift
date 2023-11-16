//
//  UILabel+Function.swift
//  xinyuancar
//
//  Created by 博识iOS One on 2020/12/2.
//

import Foundation

extension UILabel {
    func textGradient(colors: [Any]?, startPoint: CGPoint, endPoint: CGPoint) {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        self.layer.insertSublayer(gradientLayer, below: self.layer)
        gradientLayer.mask = self.layer
        self.frame = gradientLayer.bounds
    }
    
    func gradientImage() -> UIImage? {
        if let str = self.text as NSString? {
            let size = str.size(withAttributes: [NSAttributedString.Key
                                                    .font: UIFont.init(name: "DINEngschriftStd", size: 90.0) ?? UIFont.systemFont(ofSize: 90.0)])
            
            let width = size.width
            let height = size.height
            
            // create a new bitmap image context
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            // get context
            if let context = UIGraphicsGetCurrentContext() {
                // push context to make it current (need to do this manually because we are not drawing in a UIView)
                UIGraphicsPushContext(context)
                
                // draw gradient
                let locations: [CGFloat] = [0.0, 1.0]
                let components: [CGFloat] = [36.0/255.0, 38.0/255.0, 38.0/255.0, 1.0, 192.0/255.0, 192.0/255.0, 192.0/255.0, 1.0, 138.0/255.0, 138.0/255.0, 139.0/255.0, 1.0]
                let rgbColorspace = CGColorSpaceCreateDeviceRGB()
                let glossGradient = CGGradient(colorSpace: rgbColorspace, colorComponents: components, locations: locations, count: 2)
                let topCenter = CGPoint(x: 0, y: 0)
                let bottomCenter = CGPoint(x: 0, y: height)
                context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: .drawsBeforeStartLocation)
                
                // pop context
                UIGraphicsPopContext()
                
                // get a UIImage from the image context
                let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
                
                // clean up drawing environment
                UIGraphicsEndImageContext()
                
                return gradientImage
            }
        }
        
        return nil
    }
}
