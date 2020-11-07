//
//  GSGlobalSearchScanView.swift
//  Shopor
//
//  Created by Ratheesh on 13/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import AVKit

protocol GlobalSearchScanDelegate: class {
    
    func scanCompletedWith(upc: String)
}

class GSGlobalSearchScanView: NibView {
    
    @IBOutlet weak var viewPreview: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var animatedLineView = UIView()
    
    var lineView = UIView()
    
    weak var delegate: GlobalSearchScanDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    private func setUpView() {
        
        self.addObserver(self, forKeyPath: "viewPreview.bounds", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "viewPreview.bounds") {
            
            if videoPreviewLayer != nil {
                videoPreviewLayer.frame = viewPreview.bounds
            }
            if animatedLineView.isDescendant(of: viewPreview) {
                animatedLineView.frame = viewPreview.bounds
            }
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    
    @IBAction func close_action(_ sender: UIButton) {
        
        removeFromSuperview()
    }
    
    // MARK: - Reloading Views After Orientation
    
    func reloadViewAfterOrientation() {
        videoPreviewLayer.frame = viewPreview.layer.bounds
        let previewLayerConnection = videoPreviewLayer.connection
        if (previewLayerConnection?.isVideoOrientationSupported)! {
            let orientation = UIApplication.shared.statusBarOrientation
            var avOrientaton = AVCaptureVideoOrientation.portrait
            
            switch orientation {
                
            case .unknown:
                avOrientaton = .portrait
                break
            case .portrait:
                avOrientaton = .portrait
                break
            case .portraitUpsideDown:
                avOrientaton = .portraitUpsideDown
                break
            case .landscapeLeft:
                avOrientaton = .landscapeLeft
                break
            case .landscapeRight:
                avOrientaton = .landscapeRight
                break
            }
            previewLayerConnection?.videoOrientation = avOrientaton
        }
    }
    
    // MARK: - Functional Methods
    
    func startReading() -> Bool {
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch let error as NSError {
            
            print(error)
            return false
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = viewPreview.layer.bounds
        viewPreview.layer.addSublayer(videoPreviewLayer)
        
        reloadViewAfterOrientation()
        
        lineView = UIView()
        viewPreview.addSubview(lineView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        lineView.leftAnchor.constraint(equalTo: viewPreview.leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: viewPreview.rightAnchor).isActive = true
        lineView.centerYAnchor.constraint(equalTo: viewPreview.centerYAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        lineView.backgroundColor = UIColor.red
        
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.upce,AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.code128]
        print(captureMetadataOutput.availableMetadataObjectTypes)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
        
        return true
    }
    
    @objc func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        
        if (videoPreviewLayer) != nil{
            
            videoPreviewLayer.removeFromSuperlayer()
            
        }
        
        if lineView.isDescendant(of: viewPreview) {
            lineView.removeFromSuperview()
        }
    }
    
    // MARK: - de init method
    
    deinit {
        removeObserver(self, forKeyPath: "viewPreview.bounds")
    }
    
    
    @IBAction func scan_action(_ sender: UIButton) {
    }
}

//MARK: - QRCode/BarCode Methods

extension GSGlobalSearchScanView : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for data in metadataObjects {
            let metaData = data
            print(metaData.description)
            //            addProductView.isHidden = false
            //            scanView.isHidden = true
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                print()
                let numberString = unwraped.stringValue!
                let numberAsInt = Int64(numberString.removeEnclosedWhieteSpace()) ?? 0
                let backToString = "\(numberAsInt)"
                
                delegate?.scanCompletedWith(upc: backToString)
                
                return
            }
        }
    }
}
