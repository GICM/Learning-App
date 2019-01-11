//
//  CapturePiechartsVC.swift
//  GICM
//
//  Created by Rafi on 11/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Charts
//import TesseractOCR
//import SwiftOCR
import FirebaseMLVision
import Firebase
import Instabug

class CapturePiechartsVC: UIViewController{
    
    //   var tesss:G8Tesseract?
    
    //  let swiftOCRInstance = SwiftOCR()
    
    var strChartDataArray = [Double]()//
    @IBOutlet weak var btnTorch: UIButton!
    
    @IBOutlet weak var vwScreenShot: UIView!
//    var textDetector: VisionTextDetector!
  //  var cloudTextDetector: VisionCloudTextDetector!
    var imageChart : UIImage?
    @IBOutlet weak var btnCameraImage: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var piechart: PieChartView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput : AVCapturePhotoOutput?
    
    var colors: [UIColor] = [.green,.blue,.orange,.purple,.brown,.cyan,.yellow,.magenta,.gray,.red]
    var viewPDF : UIView?
    var capturePDF : CapturePDF?
    // var imageArry:[UIImage] = []
    @IBOutlet weak var imgCapture: UIImageView!
    
    var strFullText = ""
    var isFirstTime = true
    override func viewDidLoad() {
        super.viewDidLoad()
//        textDetector = Vision().textDetector()
       // cloudTextDetector = Vision().cloudTextDetector()
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressCameraImageLandscape))
//        btnCameraImage.addGestureRecognizer(longPress)
        
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        
       // let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        capturePDF = story.instantiateViewController(withIdentifier: "CapturePDF") as? CapturePDF
        self.addChildViewController(capturePDF!)
        capturePDF!.didMove(toParentViewController: self)
        
        capturePDF?.closeBtnClosure = {
            self.viewPDF!.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupPiechart()
        self.setupCamera()
    }
    
    //MARK:- Button Actions
    var torchOn = true
    @IBAction func torchAction(_ sender: Any) {
        if torchOn{
            Utility.sharedInstance.toggleTorch(on: torchOn)
            btnTorch.setImage(#imageLiteral(resourceName: "flashOn"), for: .normal)
            torchOn = !torchOn
        }else{
            Utility.sharedInstance.toggleTorch(on: torchOn)
             btnTorch.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
            torchOn = true
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func Next(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "LabelsPiechartsVC") as! LabelsPiechartsVC
        
        if self.strChartDataArray.isEmpty{
            vc.arrLabelsOfChartData = [100.0]
        }else{
            vc.arrLabelsOfChartData = self.strChartDataArray
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    @IBAction func instaBug(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        
        
        //
        //        let dict = ["user_id": "1",//UserDefaults.standard.getUserID(),
        //            "type_of_capture": UserDefaults.standard.string(forKey: "type_of_capture") ?? "",
        //            "title": ""] as [String : Any]  //self.lblTitle.text ?? ""
        //
        //        imageChart = self.screenShot(with: piechart)
        //        let data = UIImageJPEGRepresentation(imageChart!,1.0)
        //        WebserviceManager.shared.showMBProgress(view:self.view)
        //        self.fileUploadPOSTServiceCall(serviceURLString: "http://cipldev.com/gicm/api/capture", uploadFileData: data! as NSData,sourceName: self.randomString(length: 10) as NSString, params: dict as NSDictionary) { (res) in
        //
        //            DispatchQueue.main.async(execute: {
        //                print(res)
        //                WebserviceManager.shared.hideMBProgress(view: self.view)
        //                // self.navigationController?.popViewController(animated: true)
        //                self.backToCaptureList()
        //            })
        //        }
        
        viewPDF = capturePDF!.view
        self.view.addSubview(viewPDF!)
        viewPDF!.frame = self.view.frame
        viewPDF?.isHidden = true
        capturePDF?.showView(chartImg: self.screenShot(with: self.vwScreenShot)!)
        self.backToCaptureList()
        //        DispatchQueue.main.async {
        //            self.imgCapture.image = imgView
        //            self.imgCapture.isHidden = false
        //        }
        
        //VisionAPI(visionImage: #imageLiteral(resourceName: "PieChart"))
        
    }
    
    func backToCaptureList(){
        for controller in self.navigationController!.viewControllers as Array
        {
            print(self.navigationController!.viewControllers as Array);
            
            if controller is CaptureVC
            {
                let _ =  self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    //Screen Shot
    func screenShot(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    @IBAction func captureAction(_ sender: Any) {
        
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
    
    @IBAction func zoomAction(_ sender: UISlider) {
        let value = sender.value
        Utilities.zoomCamera(value: value)
    }
    
    @IBAction func Camera(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
        
    }
    
    //MARK:- Local Methods
    fileprivate func setupPiechart() {
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            
            var unitsSold = [100.0]
            if self.strChartDataArray.isEmpty{
                unitsSold = [100.0]
            }else{
                unitsSold = self.strChartDataArray
            }
            
            self.piechart.delegate = self
            self.setChart( values: unitsSold)
        }
    }
    
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
            videoPreviewLayer?.frame = previewView.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
    
    func VisionAPI(visionImage: UIImage){
        
        // let img = UIImage(named: "3")
        
        var strConvert = ""
        GoogleVisonAPI_Handler.sharedInstance.getTyreSize(image:visionImage, completion: {infoString, status in
            DispatchQueue.main.async {
                self.imgCapture.isHidden = true
                if status
                {
                    print(infoString)
                    
                    strConvert.append(infoString)
                    
                    self.strFullText.append(infoString)
                    
                    let trimmedString = strConvert.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trim = trimmedString.trimmingCharacters(in: .whitespaces)
                    
                    print(trim)
                    if let chartValue = Double(trim){
                        self.strChartDataArray.append(chartValue)
                        
                        print("FULL TEXT",self.strChartDataArray)
                        
                        // yChartArray.
                        self.setChart( values: self.strChartDataArray)
                    }
                    
                    Utilities.displayFailureAlertWithMessage(title: "Success", message: self.strFullText, controller: self)
                }else{
                    //                    Utilities.displayFailureAlertWithMessage(title: "Attention!!", message: self.strFullText, controller: self)
                }
            }
        })
    }
    
    //MARK:- Tesseract
    func imageToText(convertImage: UIImage){
        
        //        swiftOCRInstance.recognize(convertImage) { recognizedString in
        //            print(recognizedString)
        //        }
        
        // let img = UIImage(named: "3")
        self.imgCapture.isHidden = true
        _ = ""
        _ = VisionImage(image: convertImage)
        
//        textDetector.detect(in: visionImage) { result, error in
//            guard error == nil, let features = result else {
//                // ...
//                return
//            }
//            
//            for text in features {
//                if let block = text as? VisionTextBlock {
//                    for line in block.lines {
//                        for element in line.elements {
//                            print(element.text)
//                            strConvert.append(element.text)
//                        }
//                    }
//                }
//            }
//            
//            let trimmedString = strConvert.trimmingCharacters(in: .whitespacesAndNewlines)
//            let trim = trimmedString.trimmingCharacters(in: .whitespaces)
//            
//            print(trim)
//            if let chartValue = Double(trim){
//                self.strChartDataArray.append(chartValue)
//                print("FULL TEXT",self.strChartDataArray)
//                self.setChart( values: self.strChartDataArray)
//            }
//            
//        }
        
        //       tesss = G8Tesseract(language: "eng")
        //        tesss?.delegate = self
        //
        ////        let tesseract:G8Tesseract = G8Tesseract(language: "eng")
        ////
        ////      //  var imageToCheck = UIImage(named: "Login")
        //     //   tesss?.charWhitelist = "0123456789."
        //        tesss?.image = convertImage
        //
        //        tesss?.recognize()
        //        print("The 1 text is \(tesss?.recognizedText ?? "")")
        //
        //        self.strFullText.append((tesss?.recognizedText ?? ""))
        //        //Utilities.displayFailureAlertWithMessage(title: "Success", message: self.strFullText, controller: self)
        
        
    }
    
    //Long Press
    @objc func longPressCameraImageLandscape(gesture:UILongPressGestureRecognizer) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
    }
    
    
    //MARK:- API
    func fileUploadPOSTServiceCall (serviceURLString : NSString, uploadFileData : NSData, sourceName : NSString, params : NSDictionary,onCompletion : @escaping (_ serviceResponse : AnyObject) -> Void) {
        
        
        let serviceURLString = NSString (string: serviceURLString)
        let serviceURL = NSURL (string: serviceURLString as String)
        let serviceURLRequest = NSMutableURLRequest (url: serviceURL! as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
        serviceURLRequest .httpMethod = "POST"
        serviceURLRequest .addValue("application/json", forHTTPHeaderField: "Content-Type")
        serviceURLRequest .addValue("application/json", forHTTPHeaderField: "Accept")
        serviceURLRequest .addValue("text/html", forHTTPHeaderField: "Accept")
        let  boundary = "Boundary-\(NSUUID().uuidString)"
        serviceURLRequest .setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData();
        
        for (key, value) in params {
            body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
            body .append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" .data(using: String.Encoding.utf8)!)
            body .append("\(value)\r\n" .data(using: String.Encoding.utf8)!)
        }
        
        let fileNameFormat = NSString (format: "%@.jpg", sourceName)
        let fileNameFormat2 = NSString (format: "%@.jpg", self.randomString(length: 10) as NSString)
        let filename = fileNameFormat
        let mimetype = "image/jpg"
        
        // chart file
        body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
        body .append("Content-Disposition: form-data; name=\"chart_image\"; filename=\"\(filename)\"\r\n" .data(using: String.Encoding.utf8)!)
        body .append("Content-Type: \(mimetype)\r\n\r\n" .data(using: String.Encoding.utf8)!)
        body .append(uploadFileData as Data)
        body.append("\r\n" .data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n" .data(using: String.Encoding.utf8)!)
        
        // full screen image
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if app.imageFullScreenMeeting.count > 0 {
            body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
            body .append("Content-Disposition: form-data; name=\"whiteboard_image\"; filename=\"\(fileNameFormat2)\"\r\n" .data(using: String.Encoding.utf8)!)
            body .append("Content-Type: \(mimetype)\r\n\r\n" .data(using: String.Encoding.utf8)!)
            body .append(app.imageFullScreenMeeting[0])
            // body .append(uploadFileData as Data)
            body.append("\r\n" .data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n" .data(using: String.Encoding.utf8)!)
        }
        
        
        serviceURLRequest .httpBody = body as Data
        
        let rmiServiceURLSession = URLSession .shared
        let rmiServiceURLSessionDataTask = rmiServiceURLSession .dataTask(with: serviceURLRequest as URLRequest, completionHandler: {(serviceURLData, serviceURLResponse, serviceURLError) in
            if serviceURLError != nil {
                print(serviceURLError? .localizedDescription ?? "")
            } else {
                print(String(data: serviceURLData!, encoding: .utf8)!)
                do {
                    let serviceResponse = try JSONSerialization .jsonObject(with: serviceURLData!, options: JSONSerialization.ReadingOptions .allowFragments)
                    onCompletion (serviceResponse as AnyObject)
                } catch {
                    print("Cannot convert json from service data")
                }
            }
        })
        rmiServiceURLSessionDataTask .resume()
    }
    
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
}

extension CapturePiechartsVC:AVCapturePhotoCaptureDelegate  {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            //            print(UIImage(data: dataImage))
            
            //            let imgScreenShot = Utilities.takeScreenshot(view: previewView)
            //            let imgView = imgScreenShot.image
            //
            //            DispatchQueue.main.async {
            //                self.imgCapture.image = imgView
            //                self.imgCapture.isHidden = false
            //                self.VisionAPI(visionImage: imgView!)
            //            }
            
            if let img = UIImage(data: dataImage){
                // let filter = img.noir  // Filter
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: img)
                    imageView.frame = UIScreen.main.bounds
                    _ = imageView.image
                    
                   // print(imageView.fr)
                    let cropImage = Utilities.cropToBounds(image: img, width: Double(self.previewView.frame.width - 100), height: Double(self.previewView.frame.height - 100))
                    
                    let imgFilter = cropImage.noir
                    self.imgCapture.image = cropImage
                    self.imgCapture.isHidden = false
                    self.VisionAPI(visionImage: imgFilter!)
                    // self.imageToText(convertImage:imgFilter!)
                }
            }
            // Your Image
        }
    }
    
}

//MARK:- Chart
extension CapturePiechartsVC :ChartViewDelegate{
    func setChart( values: [Double]) {
        piechart.noDataText = "you need to provide data for chart"
        
        var dataEntries: [ChartDataEntry] = []
        //piechart.centerText = " "
        for i in 0..<values.count {
            
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        _ = PieChartDataSet(values: dataEntries, label: "")
        
        //var colors: [UIColor] = []
        //
        //        for _ in 0..<values.count {
        //            let red = Double(arc4random_uniform(256))
        //            let green = Double(arc4random_uniform(256))
        //            let blue = Double(arc4random_uniform(256))
        //
        //            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        //            colors.append(color)
        //
        //            pieChartDataSet.colors = colors
        //        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: dataEntries, label:"Meeting")
        dataSet.sliceSpace = 0
        dataSet.selectionShift = 7.0
        dataSet.colors = colors
        dataSet.yValuePosition = .insideSlice
        dataSet.entryLabelColor = .clear
        dataSet.axisDependency =  .left
        
        dataSet.valueTextColor = .black
        
        dataSet.drawValuesEnabled = true
        dataSet.valueLineVariableLength = true
        
        let data: PieChartData = PieChartData(dataSet: dataSet)
        piechart.data = data
        
        let format = NumberFormatter()
        format.numberStyle = .percent
        format.maximumFractionDigits = 1
        format.multiplier = 1
        format.zeroSymbol = ""
        piechart.data?.setValueFormatter(DefaultValueFormatter(formatter: format))
        piechart.rotationAngle = 90.0
        piechart.setExtraOffsets(left: 0, top: 5, right: 0, bottom: 0)
        
        if isFirstTime{
            piechart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
        }else{
            
        }
        isFirstTime = !isFirstTime
        piechart.drawHoleEnabled = false
        piechart.legend.enabled = false
        piechart.chartDescription?.text = ""
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
