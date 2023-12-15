//
//  QRCodeScannerViewController.swift
//  PZXMapDemo
//
//  Created by 彭祖鑫 on 2023/11/22.
//

import AVFoundation
import UIKit
import Vision

class QRCodeScannerViewController: RootViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var highlightView: UIView!
    var isFlashlightOn = false
    
    var scanAnimationView: PZXScanAnimationView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.isHidden = true
        self.view.backgroundColor = .black
        // 创建 AVCaptureSession
        captureSession = AVCaptureSession()

        // 获取默认后置摄像头
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            // 创建 AVCaptureDeviceInput 对象
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print(error)
            return
        }

        // 将 videoInput 添加到 captureSession
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        // 创建 AVCaptureMetadataOutput 对象，并将其添加到 captureSession
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            // 设置在预览图层上检测所有支持的码类型
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // 创建预览图层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // 启动 captureSession
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
        
        // 创建用于高亮显示二维码的红色圆形视图
        highlightView = UIView()
//        highlightView.layer.borderColor = UIColor.red.cgColor
//        highlightView.layer.borderWidth = 2
        highlightView.layer.cornerRadius = 8
        highlightView.backgroundColor = .red
        highlightView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        highlightView.isHidden = true
        view.addSubview(highlightView)
        
        
        
        
        scanAnimationView = PZXScanAnimationView(frame: CGRect(x: 36, y: TOP_HEIGHT, width: SCREEN_WIDTH - 72, height: SCREEN_HEIGHT - TOP_HEIGHT - 180))
        view.addSubview(scanAnimationView)
        scanAnimationView.startScanAnimation()

        
        let leftButton = UIButton(type: .custom)
        leftButton.setTitle("开灯", for: .normal)
        leftButton.frame = CGRect(x: 20, y: SCREEN_HEIGHT - 140, width: 80, height: 40)
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.backgroundColor = .brown
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(leftButton)
        
        
        let rightButton = UIButton(type: .custom)
        rightButton.setTitle("相册", for: .normal)
        rightButton.frame = CGRect(x: SCREEN_WIDTH - 100, y: SCREEN_HEIGHT - 140, width: 80, height: 40)
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.backgroundColor = .brown
        rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
        self.view.addSubview(rightButton)
        
    }
    
    @objc func leftButtonPressed(){
        
        print("点击开灯")
        toggleFlashlight()

        
    }
    
    @objc func rightButtonPressed(){
        
        ZLPhotoConfiguration.default().maxSelectCount =  1
        ZLPhotoConfiguration.default().allowEditImage = false
        ZLPhotoConfiguration.default().allowSelectOriginal = false
        ZLPhotoConfiguration.default().selectImageBlockBack = false
        ZLPhotoConfiguration.default().allowTakePhotoInLibrary = false

        print("点击相册")
        let ps = ZLPhotoPreviewSheet()
        
        ps.selectImageBlock = { [weak self] results, isOriginal in
            // your code
//            let qrCodeScanner = self?.QRCodeScanner()
            let image = results.first!.image
            


            self?.scanQRCode(from: image)


        }
        
        ps.showPhotoLibrary(sender: self)

        
    }
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            // 锁定设备配置，以便可以修改设备属性
            try device.lockForConfiguration()

            // 切换闪光灯状态
            if isFlashlightOn {
                device.torchMode = .off
            } else {
                device.torchMode = .on
            }

            // 更新闪光灯状态
            isFlashlightOn = !isFlashlightOn

            // 解锁设备配置
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flashlight: \(error)")
        }
    }

    // AVCaptureMetadataOutputObjectsDelegate 方法，处理扫描结果
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(1007))
            AudioServicesPlaySystemSound(1007)

            
            // 获取二维码中心坐标
            let barcodeObject = previewLayer.transformedMetadataObject(for: metadataObject)
//            highlightView.frame = barcodeObject!.bounds

                     // 在中心点显示红色圆形视图
            highlightView.center = CGPoint(x: barcodeObject!.bounds.midX, y: barcodeObject!.bounds.midY)
            highlightView.isHidden = false
            scanAnimationView.stopScanAnimation()
            scanAnimationView.isHidden = true

            // 处理扫描到的二维码
            print("扫描结果: \(stringValue)")
        }

        dismiss(animated: true)
    }

    // Helper 方法，处理初始化失败
    func failed() {
        let ac = UIAlertController(title: "扫描不可用", message: "请检查您的设备是否支持摄像头，并且授权应用访问摄像头。", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    
    func scanQRCode(from image: UIImage) {
        // 将 UIImage 转换为 CIImage
        guard let ciImage = CIImage(image: image) else {
            print("Error converting UIImage to CIImage.")
            return
        }

        // 创建 CIDetector
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)

        // 获取识别结果
        let features = detector?.features(in: ciImage)

        // 处理识别结果
        if let firstFeature = features?.first as? CIQRCodeFeature {
            let scannedValue = firstFeature.messageString
            AudioServicesPlaySystemSound(1000);
            ZLPhotoConfiguration.default().highlightView.isHidden = false
            print("scannedValue = \(scannedValue ?? "")")
            ///截屏，添加到当前View
            let imageView = UIImageView(frame: PZXKeyController().view.bounds)
            if let screenshotImage = PZXKeyController().view.screenshot() {
                // 现在你可以使用 screenshotImage，比如保存到相册或展示在 UIImageView 中
                // 例如：imageView.image = screenshotImage
                imageView.image = screenshotImage
                self.view.addSubview(imageView)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8) {
                
                PZXKeyController().dismiss(animated: false) {
                    let vc = ChargeGunViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            }
  

            
            
        } else {
            print("No QR Code detected.")
        }
    }
    
}
