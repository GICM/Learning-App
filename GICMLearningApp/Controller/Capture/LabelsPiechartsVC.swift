//
//  LabelsPiechartsVC.swift
//  GICM
//
//  Created by CIPL on 13/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Charts
import Instabug
import AVKit
import AVFoundation

var arrChart = [Double]()
var arrChartData = [String]()

class LabelsPiechartsVC: UIViewController {
    
    @IBOutlet weak var btnCameraImage: UIButton!
    
    @IBOutlet weak var btnTorch: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var piechart: PieChartView!
    @IBOutlet weak var vwScreenShot: UIView!
    var imageChart : UIImage?
    
    var arrLabelsOfChartData = [Double]()
    var arrStringData = [String]()
    
    //Local ChartData
    var arrLabelValues = [String]()
    
    var isFirstTime = true
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput : AVCapturePhotoOutput?
    var colors: [UIColor] = [.green,.blue,.orange,.purple,.brown,.cyan,.yellow,.magenta,.gray,.red]
    
    @IBOutlet weak var imgCapture: UIImageView!
    var strFullText = ""
    
    var fromVC = "First"
    var viewPDF : UIView?
    var capturePDF : CapturePDF?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressCameraImageLandscape))
//        btnCameraImage.addGestureRecognizer(longPress)
        
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        capturePDF = story.instantiateViewController(withIdentifier: "CapturePDF") as? CapturePDF
        self.addChildViewController(capturePDF!)
        capturePDF!.didMove(toParentViewController: self)
        
        capturePDF?.closeBtnClosure = {
            self.viewPDF!.removeFromSuperview()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupPiechart()
        NSLog("***********************************************")
        NSLog(" Capture View did load  ")
        self.setupCamera()
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
    
    @IBAction func Camera(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
        
    }
    
    
    @IBAction func instaBug(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        //                //self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func Next(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CaptionPiechartsVC") as! CaptionPiechartsVC
        vc.arrChartData = self.arrLabelsOfChartData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK:- Local Methods
    fileprivate func setupPiechart() {
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            // let unitsSold = [100.0]
            
            for _ in self.arrLabelsOfChartData{
                self.arrStringData.append("")
            }
            
            arrChartData = self.arrStringData
            arrChart = self.arrLabelsOfChartData
            self.piechart.delegate = self
            self.setChart( values: self.arrLabelsOfChartData)
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
                    
                    self.arrStringData.removeAll()
                    self.arrLabelValues.append(trim)
                    self.arrStringData = self.arrLabelValues
                    
                    print("FULL TEXT",self.arrStringData)
                    
                    self.validateChartDetails()
                    
                    Utilities.displayFailureAlertWithMessage(title: "Success", message: self.strFullText, controller: self)
                }else{
                    //Utilities.displayFailureAlertWithMessage(title: "Attention!!", message: self.strFullText, controller: self)
                }
            }
        })
    }
    
    
    func validateChartDetails(){
        
        for _ in arrLabelsOfChartData{
            if self.arrStringData.count <= self.arrLabelsOfChartData.count{
                self.arrStringData.append("")
            }else{
                return
            }
            
            arrChartData = self.arrStringData
            arrChart = self.arrLabelsOfChartData
            print("Chart ARRAY  -------> ",arrChartData)
            self.setChart(values: self.arrLabelsOfChartData)
        }
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
    
    //MARK:- Random Number
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



extension LabelsPiechartsVC:AVCapturePhotoCaptureDelegate  {
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
                    
                    let cropImage = Utilities.cropToBounds(image: img, width: Double(self.previewView.frame.width), height: Double(self.previewView.frame.height))
                    
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
extension LabelsPiechartsVC :ChartViewDelegate{
    func setChart( values: [Double]) {
        
        if fromVC == "First"{
            self.arrStringData.removeAll()
            fromVC = "second"
        }
        
        piechart.noDataText = "you need to provide data for chart"
        
        var dataEntries: [ChartDataEntry] = []
        //piechart.centerText = " "
        for i in 0..<values.count {
            
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
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
        piechart.data?.setValueFormatter(LabelValueFormatter())
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

class LabelValueFormatter: DefaultValueFormatter {
    override func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        //arrChartData = ["kanna","Prabhu","Chandru"]
        //  let yValueArray = [25.0,35.0,40.0]
        
        let index = arrChart.index(of: entry.y)
        let returnStr = "\(arrChartData[index ?? 0]) \(entry.y)%"
        return  returnStr
    }
}

