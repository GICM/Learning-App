//
//  MeetingVC.swift
//  GICM
//
//  Created by Rafi on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Charts
import CoreLocation
import FirebaseAuth
import PDFGenerator
import MessageUI
import Instabug
import FirebaseStorage
import AVKit
import AVFoundation


//let API_KEY = "AIzaSyDebZV4yCrBsIXIjWOmTsNgzBtN6G1nmts"
let API_KEY = "AIzaSyDrK8B39SQpdVNgTUTfC-ZF301ZGeYnZn8"

let SAMPLE_RATE = 16000
let RECORD_DURATION = 5
let MAX_ALTERNATIVE = 1

let MAIL_HOST_NAME = "smtp.1und1.de"
let MAIL_PORT = 587
let MAIL_USERNAME = "cloud@consultingmastery.institute"
let MAIL_PASSWORD = "1234ForNow!"
let WORD_URL : NSString = "https://us-central1-gicm-mobile-app.cloudfunctions.net/appModule/sendMail"


class MeetingVC: UIViewController,ChartViewDelegate,AVAudioRecorderDelegate,MFMailComposeViewControllerDelegate,CLLocationManagerDelegate {
    
    //MARK:- Initiolization
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var btnActionitem: UIButton!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblMeetingTime: UILabel!
    @IBOutlet weak var txtViewSpeechResult: UITextView!
    @IBOutlet weak var tblPiechart: UITableView!
    @IBOutlet weak var viewFlip: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var sliderBritness: UISlider!
    
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!
    
    //  @IBOutlet weak var imgViewCapture: UIImageView!
    @IBOutlet weak var imgViewChart: UIImageView!
    @IBOutlet weak var stackPdfImg: UIStackView!
    @IBOutlet weak var stackViewSpeak: UIStackView!
    @IBOutlet weak var pdfContentView: UIView!
    @IBOutlet weak var scrollPDFView: UIScrollView!
    @IBOutlet weak var lblMeetingPDFTag: UILabel!
    @IBOutlet weak var lblMettingPDFVenue: UILabel!
    @IBOutlet weak var lblMeetingPDFDur: UILabel!
    @IBOutlet weak var lblMeetingPDFName: UILabel!
    @IBOutlet weak var btnClosePDFView: UIButton!
    @IBOutlet weak var viewPDFContainer: UIView!
    @IBOutlet weak var lblMeetingPDFDesc: UILabel!
    @IBOutlet weak var btnSendMail: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var audioRecorderFull: AVAudioRecorder?
    
    var pieChartModel = PiechartModel()
    var strMeetingName = ""
    var stringResult = ""
    var stringTag = ""
    var stringSpeechContext = ""
    var speakerCount = 2
    var stringPlace = ""
    var totalRecordingTime = 0
    var isStop = false
    var arrayResult : [[String : AnyObject]] = []
    var wordsDict: [String : String] = [:]
    var imageChart : UIImage?
    var imageTaken : UIImage?
    var isFirstTimeLoaded = true
    var locationManager:CLLocationManager!
    var dataSpeechFile:Data?
    @IBOutlet weak var vwScreenShot: UIView!
    var dataPDF:Data?
    //Chart
    var colors: [UIColor] = [.red,.green,.blue,.orange,.purple,.brown,.cyan,.yellow,.magenta,.gray]
    var arrayPiechartLegend : [String] = []
    var arrayPiechartLegendCopy : [String] = []
    
    var chartImageFileName = ""
    var takenImageFilename:[String] = []
    
    @IBOutlet weak var btnDecision: UIButton!
    @IBOutlet weak var vwActionItem: UIView!
    
    var strCurrentTime = ""
        var MeetingType = ""
    
    var audioPaused = false
    
    var actionItemChanged = false
    var actionItemDictionary = [[String: String]]()
    
    var currentActionItem = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("***********************************************")
        NSLog(" Meeting View Controller View did load  ")
        
        self.configUI()
        let currentDateTime = Date()
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        self.strCurrentTime = formatter.string(from: currentDateTime)
        
        print(self.strCurrentTime)
        //        self.view.addSubview(viewFlip)
        //        viewFlip.frame = .init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height-110)
        //        viewFlip.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.headingFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        lblMeetingName.text = strMeetingName
        
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
            Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention", message: "Please allow the microphone access to record audio", controller: self) { (dismiss) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                })
            }
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
                if !granted {
                    Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention", message: "Please allow the microphone access to record audio", controller: self) { (dismiss) in
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                        })
                    }
                }
            })
        }
        
        lblMeetingTime.text = "\(totalRecordingTime) second"
        pieChart.delegate = self
        let recordSettings = [AVEncoderAudioQualityKey: .max, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 1, AVSampleRateKey: SAMPLE_RATE]
        audioRecorder = try? AVAudioRecorder(url: soundFilePath()!, settings: recordSettings)
        audioRecorder?.delegate = self
        self.startRecording()
        self.updateRecordTime()
        
        audioRecorderFull = try? AVAudioRecorder(url: soundFilePathFullAudio()!, settings: recordSettings)
        audioRecorderFull?.delegate = self
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        audioRecorderFull?.record()
        
    }
    
    func updateRecordTime(){
        if totalRecordingTime < 2 {
            lblMeetingTime.text = "\(totalRecordingTime) second"
        }else{
            lblMeetingTime.text = "\(totalRecordingTime) seconds"
        }
        totalRecordingTime += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // your code here
            if !self.isStop {
                self.updateRecordTime()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //    func flipTransition (with view1: UIView, view2: UIView, isReverse: Bool = false) {
    //        var transitionOptions = UIViewAnimationOptions()
    //        transitionOptions = isReverse ? [.transitionFlipFromLeft] : [.transitionFlipFromRight] // options for transition
    //        UIView.transition(with: view1, duration: 1.5, options: transitionOptions, animations: {
    //            self.viewFlip.isHidden = !self.viewFlip.isHidden
    //            self.btnCamera.isHidden = !self.btnCamera.isHidden
    //            self.sliderBritness.isHidden = !self.sliderBritness.isHidden
    //        })
    //    }
    
    func flipTransition () {
        UIView.animate(withDuration: 0.5) {
            self.viewMain.transform = self.viewMain.transform.rotated(by: .pi)
        }    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if stringPlace == "" {
            self.getAddressFromLatLon(location: manager.location!)
        }
    }
    
    func configUI(){
        if MeetingType == "AirTime" {
            self.txtViewSpeechResult.isHidden = true
            self.btnDecision.isHidden = true
            self.btnActionitem.isHidden = true
            self.vwActionItem.isHidden = true
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        self.audioRecorder?.record(forDuration: TimeInterval(RECORD_DURATION))
    }
    
    func soundFilePath() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        return docsDirect.appendingPathComponent("sound.caf")
    }
    func soundFilePathFullAudio() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        return docsDirect.appendingPathComponent("soundfull.caf")
    }
    func recordSoundFile(){
        let fileManger = FileManager.default
        let paths = fileManger.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0].appendingPathComponent("sound_full_audio.mp3")
        do {
            dataSpeechFile = try Data.init(contentsOf: soundFilePathFullAudio()!)
            try dataSpeechFile?.write(to: docsDirect)
        }
        catch  {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audio status: \(flag)")
        if !isStop && !audioPaused {
            self.processAudio()
            //            totalRecordingTime += RECORD_DURATION
            //            lblMeetingTime.text = "\(totalRecordingTime) seconds"
            startRecording()
        }
    }
    
    func processAudio() {
        var service = "https://speech.googleapis.com/v1p1beta1/speech:recognize"
        service = service + ("?key=")
        service = service + (API_KEY)
        print("Speaker count: \(speakerCount)")
        do{
            let audioData = try Data.init(contentsOf: soundFilePath()!)
            let configRequest = ["encoding": "LINEAR16", "sampleRateHertz": SAMPLE_RATE, "languageCode": "en-US", "maxAlternatives": MAX_ALTERNATIVE, "diarizationSpeakerCount": speakerCount, "enableAutomaticPunctuation": true, "enableSpeakerDiarization": true] as [String : Any]
            let audioRequest = ["content": audioData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))]
            let requestDictionary = ["config": configRequest, "audio": audioRequest]
            let requestData: Data? = try? JSONSerialization.data(withJSONObject: requestDictionary, options: [])
            let URLr =  URL.init(string: service)
            var request: URLRequest? = nil
            if let anURL = URLr {
                request = URLRequest(url: anURL)
            }
            
            request?.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request?.httpBody = requestData
            request?.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request!, completionHandler: {data, response, error in
                DispatchQueue.main.async(execute: {() -> Void in
                    do{
                        if data != nil{
                            if let json = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? [String : AnyObject]{
                                print("RESULT SPEECH: \(json)")
                                if let arraySub = json["results"] as? [[String : AnyObject]]{
                                    if arraySub.count > 0 {
                                        if let alernatives = arraySub[arraySub.count-1]["alternatives"] as? [[String : Any]] {
                                            if alernatives.count>0 {
                                                let arraySubWords = alernatives[alernatives.count-1]["words"] as! [[String : AnyObject]]
                                                if arraySubWords.count > 0 {
                                                    var transcript = ""
                                                    for word in arraySubWords{
                                                        transcript = transcript + " " + (word["word"] as! String)
                                                    }
                                                    self.txtViewSpeechResult.text = transcript
                                                    self.addActionItemDatas(strText: transcript)
                                                    self.arrayResult += arraySubWords
                                                    self.parseDataSpeech(arraySubSpeech: arraySubWords)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    catch {
                        print(error)
                    }
                })
            } )
            task.resume()
        }catch{
            print(error)
        }
    }
    
    func addActionItemDatas(strText: String){
        if actionItemChanged{
            
            let currentDateTime = Date()
            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            let time = formatter.string(from: currentDateTime)
            
            let actionItemString = "\(self.currentActionItem):, Time: \(time),Transcript: \(strText)"
            
             let actionItem = ["action":"\(actionItemString)","stakeholder":UserDefaults.standard.getUserName()]
            
            self.actionItemDictionary.append(actionItem)
        }
        print(self.actionItemDictionary)

        actionItemChanged = false
    }
    
    func parseDataSpeech(arraySubSpeech :  [[String : AnyObject]])
    {
        for dictWord in arraySubSpeech{
            let keyword = String(dictWord["speakerTag"] as? Int ?? 0)
            let existStr = wordsDict[keyword]
            let str = dictWord["word"] as! String
            if existStr != nil{
                wordsDict[keyword] = existStr! + " " + str
            }
            else{
                wordsDict[keyword] = str
            }
        }
        
        var name : [String] = []
        var value : [Int] = []
        let totalWordsCount = arrayResult.count
        for (i,val) in wordsDict{
            let arraySplit2 = val.split(separator: " ")
            name.append("Speaker \(i)")
            value.append(Int((Float(arraySplit2.count)/Float(totalWordsCount))*100))
        }
        for (i,_) in wordsDict{
            if !arrayPiechartLegendCopy.contains("Speaker \(i)"){
                arrayPiechartLegendCopy.append("Speaker \(i)")
                arrayPiechartLegend.append("Speaker \(i)")
            }
        }
        
        let bgView = UIView.init(frame:CGRect(x: 0, y: 0, width: tblPiechart.frame.size.width, height: tblPiechart.frame.size.height))
        bgView.backgroundColor = UIColor.white
        tblPiechart.backgroundView = bgView
        
        self.setChart(dataPoints: value)
        tblPiechart.reloadData()
        print("\n name-->>\(name),values ---->>\(value)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnActionitem.setTitle("Action \n Item", for: .normal)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Local Methods
    
    
    //MARK:- Button Action
    @IBOutlet weak var pausePlay: UIButton!
    @IBAction func pauseAction(_ sender: Any) {
        if audioPaused{
            self.pausePlay.setImage( UIImage(named: "pause"), for: .normal)
            self.startRecording()
        }else{
            self.pausePlay.setImage( UIImage(named: "record"), for: .normal)
        }
        self.audioPaused.toggle()
        
    }
    
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.stopRecording()
        isStop = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ActionItemsHandler(_ sender: UIButton) {
        print("\(String(describing: sender.currentTitle))")
        self.currentActionItem = "\(String(describing: sender.currentTitle ?? ""))"
        self.actionItemChanged = true
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func StopAction(_ sender: Any) {
        isStop = true
        self.stopRecording()
        //   self.recordSoundFile()
        //   self.sendSpeechChartDetails()
        // self.sendSpeechChartFirebase()
        self.uploadChartImageFile()
    }
    
    func stopRecording(){
        if audioRecorder?.isRecording ?? false {
            self.audioRecorder?.stop()
        }
    }
    func configureMail(){
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = MAIL_HOST_NAME
        smtpSession.username = MAIL_USERNAME
        smtpSession.password = MAIL_PASSWORD
        smtpSession.port = 587
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.startTLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = String(data: data!, encoding: .utf8){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        //Anonymous
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: UserDefaults.standard.getUserName(), mailbox: UserDefaults.standard.getEmail())]
        builder.header.from = MCOAddress(displayName: "GICM App", mailbox: MAIL_USERNAME)
        builder.header.subject = "GICM Meeting Report"
        builder.htmlBody = "Please find the below attached pdf."
        
        do {
            dataPDF = try PDFGenerator.generated(by: [scrollPDFView])
            pdfCloseHandler()
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.suc_mail)!)
            let attachment = MCOAttachment()
            attachment.mimeType =  "application/pdf"
            attachment.filename = "meeting.pdf"
            attachment.data = dataPDF
            builder.addAttachment(attachment)
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    NSLog("Error sending email: \(error.debugDescription)")
                } else {
                    NSLog("Successfully sent email!")
                    Constants.appDelegateRef.imageFullScreenMeeting.removeAll()
                }
            }
        } catch (let error) {
            print(error)
        }
    }
    
    func sendSpeechChartFirebase(){
        
        btnClosePDFView.isHidden = true
        btnSendMail.isHidden = true
        let imgC = self.screenShot(with: vwScreenShot)
        self.view.addSubview(viewPDFContainer)
        viewPDFContainer.frame = self.view.frame
        viewPDFContainer.isHidden = true
        var tagS = ""
        for i in 11..<15{
            if ((self.view.viewWithTag(i) as? UIButton)?.isSelected)! {
                if tagS == ""{
                    tagS = "\((self.view.viewWithTag(i) as? UIButton)?.titleLabel?.text ?? "")"
                }
                else{
                    tagS = "\(tagS),\((self.view.viewWithTag(i) as? UIButton)?.titleLabel?.text ?? "")"
                }
            }
        }
        
        lblMeetingPDFName.text = "Meeting Name: \(strMeetingName)"
        lblMeetingPDFDur.text = "Duration: \(totalRecordingTime) seconds"
        lblMettingPDFVenue.text = "Place: \(stringPlace)"
        lblMeetingPDFTag.text = "Tags: \(tagS)"
        lblMeetingPDFDesc.text = "Context: \(stringSpeechContext)"
        
        for subView in stackViewSpeak.arrangedSubviews{
            subView.removeFromSuperview()
        }
        
        for (key,val) in wordsDict{
            let lbl = UILabel.init()
            lbl.text = "Speaker \(key): \(val)"
            lbl.font = UIFont.systemFont(ofSize: 15)
            lbl.textColor = UIColor.darkGray
            lbl.numberOfLines = 0
            stackViewSpeak.addArrangedSubview(lbl)
        }
        
        imgViewChart.image = imgC
        
        if Constants.appDelegateRef.imageFullScreenMeeting.count > 0 {
            self.addCapturedImages()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.configureMail()
        })
        
        //        WebserviceManager.shared.showMBProgress(view:self.view)
        //        let ref = FirebaseManager.shared.firebaseDP?.collection("meeting")
        //        ref?.addDocument(data: self.getSpeechJson(), completion: { (error) in
        //            WebserviceManager.shared.hideMBProgress(view: self.view)
        //            self.navigationController?.popViewController(animated: true)
        //        })
        
    }
    
    func sendSpeechChartNodeFB(){
        
        WebserviceManager.shared.sendMeetingReport(view: self.view, meetingURL: WORD_URL as String, dictBody: self.getSpeechJson(), Success: { (status) in
            
            DispatchQueue.main.async(execute: {
                WebserviceManager.shared.hideMBProgress(view: self.view)
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.suc_mail)!)
                Constants.appDelegateRef.imageFullScreenMeeting.removeAll()
                self.navigationController?.popViewController(animated: true)
            })
        }) { (status) in
            DispatchQueue.main.async(execute: {
                WebserviceManager.shared.hideMBProgress(view: self.view)
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.failed)!)
            })
        }
    }
    
    func uploadChartImageFile(){
        WebserviceManager.shared.showMBProgress(view: self.view)
        imageChart = self.screenShot(with: vwScreenShot)
        let data = UIImageJPEGRepresentation(imageChart!,0.5)
        chartImageFileName = Utility.sharedInstance.randomString(length: 6)
        chartImageFileName = "\(chartImageFileName).jpg"
        let refStorage = Storage.storage().reference().child("uploads_word").child("\(chartImageFileName)")
        refStorage.putData(data!, metadata: nil) { (storageMeta, error) in
            refStorage.downloadURL(completion: { (url, error) in
                let strFileTake = "https://storage.googleapis.com/gicm-mobile-app.appspot.com/uploads_word/\(self.chartImageFileName)"
                self.chartImageFileName = strFileTake
                if Constants.appDelegateRef.imageFullScreenMeeting.count > 0
                {
                    self.uploadTakenImageFile()
                }else{
                    self.sendSpeechChartNodeFB()
                }
            })
        }
    }
    
    func uploadTakenImageFile(){
        takenImageFilename.removeAll()
        for dataImg in Constants.appDelegateRef.imageFullScreenMeeting{
            var fileName = Utility.sharedInstance.randomString(length: 6)
            fileName = "\(fileName).jpg"
            let refStorage = Storage.storage().reference().child("uploads_word").child("\(fileName)")
            refStorage.putData(dataImg, metadata: nil) { (storageMeta, error) in
                refStorage.downloadURL(completion: { (url, error) in
                    let strFileTake = "https://storage.googleapis.com/gicm-mobile-app.appspot.com/uploads_word/\(fileName)"
                    self.takenImageFilename.append((strFileTake))
                    if  Constants.appDelegateRef.imageFullScreenMeeting.count == self.takenImageFilename.count
                    {
                        self.sendSpeechChartNodeFB()
                    }
                })
            }
        }
    }
    
    func addCapturedImages(){
        for imgData in Constants.appDelegateRef.imageFullScreenMeeting{
            let imgView = UIImageView .init(image:  UIImage.init(data: imgData))
            imgView.contentMode = .scaleAspectFit
            stackPdfImg!.addArrangedSubview(imgView)
        }
    }
    
    @IBAction func pdfCloseHandler(){
        viewPDFContainer.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pdfSendMail(){
        
        do {
            btnClosePDFView.isHidden = true
            btnSendMail.isHidden = true
            dataPDF = try PDFGenerator.generated(by: [scrollPDFView])
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }        } catch (let error) {
                print(error)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["\(UserDefaults.standard.getEmail())"])
        mailComposerVC.setSubject("Meeting Report from GICM")
        mailComposerVC.setMessageBody("Please find the below attached pdf", isHTML: false)
        mailComposerVC.addAttachmentData(dataPDF!, mimeType: "application/pdf", fileName: "meeting.pdf")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        Utilities.displayFailureAlertWithMessage(title: "Alert", message: "Your device could not send e-mail.  Please check e-mail configuration and try again", controller: self)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        self.pdfCloseHandler()
        btnClosePDFView.isHidden = false
        btnSendMail.isHidden = false
    }
    
    func getSpeechJson() ->  [String:Any]{
        for i in 11..<15{
            if ((self.view.viewWithTag(i) as? UIButton)?.isSelected)! {
                stringTag = "\(stringTag),\((self.view.viewWithTag(i) as? UIButton)?.titleLabel?.text ?? "")"
            }
        }
        var arraySpeaker : [[String:String]] = []
        var j = 0
        for (_,val) in wordsDict{
            let dict = ["name":arrayPiechartLegend[j],"speech":val,"role":"Manager \(j)"] as [String:String]
            j += 1
            arraySpeaker.append(dict)
        }
        
        var isTranscipt = true
        if MeetingType == "AirTime" {
            arraySpeaker.removeAll()
            isTranscipt = false
        }
        
        print(arraySpeaker)

        //        let data123 = try! JSONSerialization.data(withJSONObject: arraySpeaker, options: .prettyPrinted)
        //        let jsonString = String(data: data123, encoding: .utf8)!
        
        //        imageChart = self.screenShot(with: vwScreenShot)
        //        let data = UIImageJPEGRepresentation(imageChart!,0.5)
        
      //  let actionItem = ["action":"Action Item 1","stakeholder":UserDefaults.standard.getUserName()]
        
        let dict = ["user_id": UserDefaults.standard.getUserID(),
                    "meeting_name":strMeetingName,
                    "recording_time":"\(totalRecordingTime)",
            "speech_context":stringSpeechContext,
            "transcript": isTranscipt,
            "speaker":arraySpeaker,
            "venue":stringPlace,
            "tag":stringTag,
            "user_name":UserDefaults.standard.getUserName(),
            "emailId":UserDefaults.standard.getEmail(),
            "image":takenImageFilename,
            "chart_image":chartImageFileName,
            "actionItems": self.actionItemDictionary ?? [],
            "timing_of_meeting":self.strCurrentTime,
            "discussionPoints":[["topic":"topicA","name":"TBD","subTopic":["sub1","sub2","sub3"]]]
            ] as [String : Any]
        return dict
    }
    func sendSpeechChartDetails(){
        
        for i in 11..<15{
            if ((self.view.viewWithTag(i) as? UIButton)?.isSelected)! {
                if stringTag.count == 0{
                    stringTag = "\((self.view.viewWithTag(i) as? UIButton)?.titleLabel?.text ?? "")"
                }
                else{
                    stringTag = "\(stringTag),\((self.view.viewWithTag(i) as? UIButton)?.titleLabel?.text ?? "")"
                }
            }
        }
        var arraySpeaker : [[String:String]] = []
        var j = 0
        for (_,val) in wordsDict{
            let dict = ["name":arrayPiechartLegend[j],"speech":val] as [String:String]
            j += 1
            arraySpeaker.append(dict)
        }
        
        let data123 = try! JSONSerialization.data(withJSONObject: arraySpeaker, options: .prettyPrinted)
        let jsonString = String(data: data123, encoding: .utf8)!
        
        let dict = ["user_id": UserDefaults.standard.getUserID(),
                    "meeting_name":strMeetingName,
                    "recording_time":"\(totalRecordingTime/60)",
            "speech_context":stringSpeechContext,
            "speaker":jsonString,
            "venue":stringPlace,
            "user_name":UserDefaults.standard.getUserName(),
            "emailId":UserDefaults.standard.getEmail(),
            "tags":stringTag] as [String : Any]
        
        imageChart = self.screenShot(with: vwScreenShot)
        let data = UIImageJPEGRepresentation(imageChart!,0.8)
        WebserviceManager.shared.showMBProgress(view:self.view)
        self.fileUploadPOSTServiceCall(serviceURLString: WORD_URL, uploadFileData: data! as NSData,sourceName: self.randomString(length: 10) as NSString, params: dict as NSDictionary) { (res) in
            
            DispatchQueue.main.async(execute: {
                print(res)
                WebserviceManager.shared.hideMBProgress(view: self.view)
                self.navigationController?.popViewController(animated: true)
            })
            
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
    
    
    
    @IBAction func flipHandler(sender:UIButton)
    {
        //        self.flipTransition(with: viewFlip, view2: viewMain,isReverse:!self.viewFlip.isHidden )
        self.flipTransition()
    }
    
    @IBAction func brightness(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    //MARK:- Chart
    func setChart(dataPoints: [Int]) {
        
        pieChart.noDataText = "you need to provide data for chart"
        var dataEntries: [ChartDataEntry] = []
        //pieChart.centerText = " "
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value:  Double(dataPoints[i]), label: "")
            // let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
            
        }
        
        //        for _ in 0..<dataPoints.count {
        //            let red = Double(arc4random_uniform(256))
        //            let green = Double(arc4random_uniform(256))
        //            let blue = Double(arc4random_uniform(256))
        //
        //            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        //            colors.append(color)
        //        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: dataEntries, label:"")
        dataSet.sliceSpace = 5
        dataSet.selectionShift = 7.0
        dataSet.colors = colors
        dataSet.yValuePosition = .insideSlice
        dataSet.entryLabelColor = .clear
        dataSet.axisDependency =  .right
        dataSet.drawValuesEnabled = true
        dataSet.valueLineVariableLength = true
        dataSet.valueFont = .boldSystemFont(ofSize: 14)
        dataSet.valueTextColor = .black
        
        
        let data: PieChartData = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.centerText = "Airtime"
        pieChart.backgroundColor = .white
        
        let format = NumberFormatter()
        format.numberStyle = .percent
        format.maximumFractionDigits = 1
        format.multiplier = 1
        format.zeroSymbol = ""
        pieChart.data?.setValueFormatter(DefaultValueFormatter(formatter: format))
        pieChart.chartDescription?.text = ""
        if isFirstTimeLoaded {
            pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        }
        let legend =  pieChart.legend
        legend.enabled = false
        isFirstTimeLoaded = false
    }
    
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
        //        let fileNameFormat3 = NSString (format: "%@.mp3", self.randomString(length: 10) as NSString)
        
        let filename = fileNameFormat
        let mimetype = "image/jpg"
        //        let audioMimetype = "audio/mp3"
        
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
            body .append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileNameFormat2)\"\r\n" .data(using: String.Encoding.utf8)!)
            body .append("Content-Type: \(mimetype)\r\n\r\n" .data(using: String.Encoding.utf8)!)
            body .append(app.imageFullScreenMeeting[0])
            body.append("\r\n" .data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n" .data(using: String.Encoding.utf8)!)
        }
        
        // audio file
        //        body .append("--\(boundary)\r\n" .data(using: String.Encoding.utf8)!)
        //        body .append("Content-Disposition: form-data; name=\"audio_file\"; filename=\"\(fileNameFormat3)\"\r\n" .data(using: String.Encoding.utf8)!)
        //        body .append("Content-Type: \(audioMimetype)\r\n\r\n" .data(using: String.Encoding.utf8)!)
        //        body .append(dataSpeechFile!)
        //        body.append("\r\n" .data(using: String.Encoding.utf8)!)
        //        body.append("--\(boundary)--\r\n" .data(using: String.Encoding.utf8)!)
        let str = String(data: body as Data, encoding: String.Encoding.utf8)
        print("data \(String(describing: str))")
        
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
    
    func getAddressFromLatLon(location: CLLocation) {
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }else{
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        self.stringPlace = "\(String(describing: pm.locality!)), \(String(describing: pm.administrativeArea!))"
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        print(addressString)
                    }
                }
        })
    }
}
extension MeetingVC : UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPiechartLegend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PiechartLegendCell", for: indexPath) as! PiechartLegendCell
        cell.viewLegendBox.backgroundColor = colors[indexPath.row]
        cell.contentView.backgroundColor = .clear
        cell.txtfdTitle.text = arrayPiechartLegend[indexPath.row]
        cell.txtfdTitle.tag = indexPath.row
        cell.txtfdTitle.delegate = self
        return cell
    } 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let strText = textField.text else {return }
        arrayPiechartLegend[textField.tag] = strText
        tblPiechart.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}










