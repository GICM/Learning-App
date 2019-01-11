//
//  CameraOverlayVC.swift
//  GICM
//
//  Created by + on 13/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CameraOverlayVC: UIViewController {
    
    @IBOutlet weak var imgWhiteBoard: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput : AVCapturePhotoOutput?
    var isMeeting = false
    
    // MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UITapGestureRecognizer(target: self, action: #selector(self.longPressCameraImageLandscape))
        self.cameraView.addGestureRecognizer(longPress)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupCamera()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    
    @objc func longPressCameraImageLandscape(gesture:UILongPressGestureRecognizer) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput?.capturePhoto(with: settings, delegate: self)
       // self.dismiss(animated: false,completion: nil)
    }
    
    
    @IBAction func cameraAction(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    //MARK:- Button Actions
    var torchOn = true
    @IBAction func torchAction(_ sender: Any) {
        if torchOn{
            Utility.sharedInstance.toggleTorch(on: torchOn)
            torchOn = !torchOn
        }else{
            Utility.sharedInstance.toggleTorch(on: torchOn)
            torchOn = true
        }
    }
    
    // MARK: - Button actions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - Local Methods
    fileprivate func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraOutput = AVCapturePhotoOutput()
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            captureSession?.addOutput(cameraOutput!)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = cameraView.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
}


extension CameraOverlayVC:AVCapturePhotoCaptureDelegate  {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            //  if isMeeting{
            let app = UIApplication.shared.delegate as! AppDelegate
            app.imageFullScreenMeeting.append(dataImage)
//            self.navigationController?.popViewController(animated: true)
            Utilities.sharedInstance.showToast(message:(FirebaseManager.shared.toastMsgs.snap_taken)! )
            self.dismiss(animated: false,completion: nil)
            

            //  }
            
        }
    }
    // Your Image
}

