//
//  PZXScanAnimationView.swift
//  PZXMapDemo
//
//  Created by 彭祖鑫 on 2023/12/15.
//

import UIKit

class PZXScanAnimationView: UIView {
    private let scanLine = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScanLine()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScanLine()
    }

    private func setupScanLine() {
        // 创建扫描线的 UIImage
        guard let scanLineImage = UIImage(named: "scan") else {
            fatalError("Failed to load scan line image.")
        }

        // 设置扫描线的样式
        scanLine.contents = scanLineImage.cgImage
        scanLine.bounds = CGRect(x: 0, y: 0, width: frame.width, height: scanLineImage.size.height)
        scanLine.position = CGPoint(x: frame.width / 2, y: 0)

        // 添加扫描线到视图的图层
        layer.addSublayer(scanLine)
    }

    func startScanAnimation() {
        // 创建扫描线的动画
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = 0
        animation.toValue = frame.height
        animation.duration = 2.0  // 设置扫描线从上到下的动画时长
        animation.repeatCount = .infinity  // 重复动画

        // 将动画添加到扫描线图层
        scanLine.add(animation, forKey: "scanAnimation")
    }

    func stopScanAnimation() {
        // 移除扫描线的动画
        scanLine.removeAnimation(forKey: "scanAnimation")
    }
}
