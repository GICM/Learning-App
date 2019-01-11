//
//  SendCallBackVC.swift
//  GICM
//
//  Created by Rafi on 19/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import MobileCoreServices
import Zip
import FirebaseStorage
import Instabug

let CALL_BACK_MAIL = "call4backup@ConsultingMastery.Institute"
let CONTRIBUTION_MAIL = "contribution@consultingmastery.institute"

let CALL_BACK_MAIL_MAX_SIZE = 15000

class SendCallBackVC: UIViewController,UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate,AVAudioRecorderDelegate{
    
    @IBOutlet weak var twReq: UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDocs: UIButton!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    var strTitle = ""
    var strMode = "Remote"
    var strUrgency = "Urgent"
    var strDetails = ""
    var audioRecorderFull: AVAudioRecorder?
    var pathDocs : URL?
    // var pathDocsRoot : URL?
    var downloadURL : URL?
    
    var strPathDocs  = ""
    var strPathDocsZip  = ""
    
    let fileManager = FileManager.default
    let imagePicker = UIImagePickerController()
    var fileSize : UInt64 = 0
    var docId = ""
    
    var fromVC = ""
    var strContributionType = ""
    var isAttach = false
    
    var docController: UIDocumentInteractionController?
    
    //MARK:- Comment View
    @IBOutlet var vwComment: UIView!
    @IBOutlet weak var txtVwComment: UITextView!
    var strComment = ""
    var strstrType = ""
    var docsURL :URL?
    
    @IBOutlet var viewAudio: UIView!
    @IBOutlet weak var lblAudioTimer: UILabel!
    var totalRecordingTime = 0
    var pathFolder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vwComment.frame = self.view.frame
        self.vwComment.isHidden = true
        self.view.addSubview(self.vwComment)
        
        self.viewAudio.frame = self.view.frame
        self.viewAudio.isHidden = true
        self.view.addSubview(self.viewAudio)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkPendingCallbackRequest), name: Notification.Name("NofifyOfflineCallback"), object: nil)
        
        if fromVC == "Contribution"{
            self.segmentCtrl.isHidden = true
        }
        if ReachabilityManager.isConnectedToNetwork(){
            self.checkPendingCallbackRequest()
        }else{
            self.resetFolderPath()
        }
        Utility.sharedInstance.getAudioPermission()
        btnSubmit.isEnabled = false
        btnSubmit.alpha = 0.5
        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false
    }
    
    func sendMissedCallback(folPath :String)
    {
        pathFolder = folPath
        self.configPath()
        WebserviceManager.shared.showMBProgress(view:self.view)
        self.getFileSize(path:strPathDocsZip)
        self.uploadFile()
    }
    
    @objc func checkPendingCallbackRequest()
    {
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let strPathC = "\(documentsPath)"+"/call4backup"
            
            if !fileManager.fileExists(atPath:strPathC){
                self.resetFolderPath()
                return
            }
            let dirContents = try fileManager.contentsOfDirectory(atPath: strPathC)
            if dirContents.count > 0{
                let i = dirContents[0]
                let strp = "\(documentsPath)"+"/call4backup"+"/\(i)"
                let sdirContents = try fileManager.contentsOfDirectory(atPath: strp)
                if sdirContents.count == 0{
                    try fileManager.removeItem(atPath: strp)
                    self.resetFolderPath()
                }
                else{
                    // check zip file exist or not
                    let strZip = "\(documentsPath)"+"/\(i).zip"
                    if !fileManager.fileExists(atPath:strZip){
                        try fileManager.removeItem(atPath: strp)
                        self.resetFolderPath()
                    }else{
                        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.pending_call)!)
                        self.sendMissedCallback(folPath: i)
                    }
                }
            }else{
                self.resetFolderPath()
            }
        }
        catch {
            self.resetFolderPath()
            print("Error: \(error)")
        }
    }
    func resetFolderPath(){
        pathFolder = Utility.sharedInstance.randomString(length: 6)
        self.configPath()
        self.createDirectory()
    }
    
    func configPath()
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        pathDocs = nil
        pathDocs = paths!.appendingPathComponent("call4backup")
        pathDocs = pathDocs!.appendingPathComponent(pathFolder)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        strPathDocs = "\(documentsPath)"+"/call4backup"+"/\(pathFolder)"
        strPathDocsZip = "\(documentsPath)"+"/\(pathFolder).zip"
        
        print("PATH:\(String(describing: pathDocs))")
        print("sPATH:\(strPathDocs)")
        print("strPathDocsZip:\(strPathDocsZip)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.isShowMenu = true
    }
    
    func enableBtnSubmit(){
        btnSubmit.isEnabled = true
        btnSubmit.alpha = 1.0
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        strComment = ""
        txtVwComment.text = strComment
        self.vwComment.isHidden = true
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        strComment = txtVwComment.text
        let trimmedString = strComment.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.count > 0{
            self.vwComment.isHidden = true
            self.btnEdit.isSelected = true
            self.enableBtnSubmit()
        }
        else{
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.detail_empty)!)
        }
    }
    
    
    // Text View delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func showVideo(_ sender: Any) {
        isAttach = false
        self.openCamera(showVideo: true)
    }
    
    func createDirectory(){
        do{
            
            try fileManager.createDirectory(at: pathDocs!, withIntermediateDirectories: true, attributes: nil)
            
        }catch {
            print("Could not clear call_backup folder: \(error)")
        }
    }
    
    func removeExistFile(){
        do{
            if fileManager.fileExists(atPath:strPathDocs){
                try fileManager.removeItem(at: pathDocs!)
            }
            if fileManager.fileExists(atPath:strPathDocsZip){
                try fileManager.removeItem(at: URL.init(fileURLWithPath: strPathDocsZip))
            }
        }catch {
            print("Could not clear call_backup folder: \(error)")
        }
    }
    @objc func longTapAudio(sender : UIGestureRecognizer){
        if sender.state == .ended {
            btnAudio.alpha = 1.0
            self.stopRecording()
        }
        else if sender.state == .began {
            btnAudio.alpha = 0.5
            self.recordAudio()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        lblTitle.text = strTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recordAudio(){
        
        let recordSettings = [AVEncoderAudioQualityKey: .max, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 1, AVSampleRateKey: SAMPLE_RATE]
        //        AVFormatIDKey:Int(kAudioFormatMPEGLayer3)
        let fileAudio = pathDocs!.appendingPathComponent("audio.caf")
        print("PATH2:\(String(describing: fileAudio))")
        
        audioRecorderFull = try? AVAudioRecorder(url:fileAudio , settings: recordSettings)
        audioRecorderFull?.delegate = self
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        audioRecorderFull?.record()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audio status: \(flag)")
        btnAudio.isSelected = true
        self.enableBtnSubmit()
    }
    
    func stopRecording(){
        if audioRecorderFull?.isRecording ?? false {
            self.audioRecorderFull?.stop()
        }
    }
    
    @IBAction func attachment(_ sender: Any) {
        self.chooseuploadImage()
        isAttach = true
    }
    
    @IBAction func audioButtonHandler(_ sender: Any) {
        self.viewAudio.isHidden = false
        self.recordAudio()
        totalRecordingTime = 0
        updateRecordTime()
    }
    
    @IBAction func backAudioButtonHandler(_ sender: Any) {
        self.viewAudio.isHidden = true
        self.stopRecording()
    }
    
    func updateRecordTime(){
        if totalRecordingTime < 2 {
            lblAudioTimer.text = "\(totalRecordingTime) second"
        }else{
            lblAudioTimer.text = "\(totalRecordingTime) seconds"
        }
        totalRecordingTime += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // your code here
            if !self.viewAudio.isHidden {
                self.updateRecordTime()
            }
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func callBackType(_ sender: Any) {
        
        switch (sender as AnyObject).selectedSegmentIndex
        {
        case 0:
            strUrgency = "Urgent"
        case 1:
            strUrgency = "This Week"
        case 2:
            strUrgency = "Upcoming"
        default:
            break
        }
    }
    
    @IBAction func modeValueChanged(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex
        {
        case 0:
            strMode = "Remote"
        case 1:
            strMode = "Onsite"
        default:
            break
        }
    }
    
    @IBAction func addComments(_ sender: Any) {
        self.vwComment.isHidden = false
    }
    
    @IBAction func send(_ sender: Any) {
        
        if fromVC == "Contribution" &&  ReachabilityManager.isConnectedToNetwork() ==  false {
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.connect)!)
            return
        }
        strDetails = txtVwComment.text ?? ""
        do {
            let dirContents = try fileManager.contentsOfDirectory(atPath: strPathDocs)
            if dirContents.count > 0{
                WebserviceManager.shared.showMBProgress(view:self.view)
                let zipFilePath = try Zip.quickZipFiles([pathDocs!], fileName: pathFolder) // Zip
                print(zipFilePath)
                if !ReachabilityManager.isConnectedToNetwork(){
                    WebserviceManager.shared.hideMBProgress(view :self.view)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.getFileSize(path:strPathDocsZip)
                self.uploadFile()
                
            }
            else{
                if !ReachabilityManager.isConnectedToNetwork(){
                    WebserviceManager.shared.hideMBProgress(view :self.view)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                if fromVC == "Contribution"{
                    self.saveRequestContribution()
                }else{
                    self.saveRequest()
                }
            }
        }
        catch {
            print("Error: \(error)")
            WebserviceManager.shared.hideMBProgress(view: self.view)
        }
    }
    
    func getFileSize(path:String){
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = (attr[FileAttributeKey.size] as? UInt64)!
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()/1024
            print(fileSize )
        } catch {
            print("Error: \(error)")
        }
    }
    
    func saveRequest(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("call_backup")
        ref?.addDocument(data: self.getRequestJson(), completion: { (error) in
            if error  == nil{
                self.configureMail()
            }
        })
    }
    
    func getRequestJson() -> [String:Any]{
        return ["mode" : strMode,
                //  "urgency"  : strUrgency,
            "title"  : strTitle,
            "date" : Utility.sharedInstance.getCurrentDate(),
            "details" : strDetails,
            "user_id" : UserDefaults.standard.getUserID(),
            "user_name" : UserDefaults.standard.getUserName(),
            "docs_size" : fileSize ,
            "docs_url" : downloadURL?.absoluteString ?? "",
            "status" : "Awaiting response on quote",
            "doc_id" : pathFolder
            
        ]
    }
    func saveRequestContribution(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("contribution")
        ref?.addDocument(data: self.getRequestJsonContri(), completion: { (error) in
            if error  == nil{
                self.configureMail()
            }
        })
    }
    
    func getRequestJsonContri() -> [String:Any]{
        return [
            //  "urgency"  : strUrgency,
            "title"  : strTitle,
            "date" : Utility.sharedInstance.getCurrentDate(),
            "details" : strDetails,
            "user_id" : UserDefaults.standard.getUserID(),
            "user_name" : UserDefaults.standard.getUserName(),
            "docs_size" : fileSize ,
            "docs_url" : downloadURL?.absoluteString ?? "",
            "doc_id" : pathFolder
            
        ]
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
        
        let builder = MCOMessageBuilder()
        if fromVC == "Contribution"{
            builder.header.to = [MCOAddress(displayName: "Contribution Mastery", mailbox:CONTRIBUTION_MAIL)]
            builder.header.from = MCOAddress(displayName: "GICM App", mailbox: MAIL_USERNAME)
            builder.header.subject = "GICM Contribution request"
            let click = "Click here to download"
            var msg = ""
            //   var dataDcos:Data?
            let contact = "</br>Requestor: \(UserDefaults.standard.getUserName())</br>Contact: \(UserDefaults.standard.getEmail())</br>"
            if downloadURL == nil{
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br> Details: \(strDetails)\(contact)</br></br></p>"
            }
            else if fileSize > CALL_BACK_MAIL_MAX_SIZE {
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br>  Details: \(strDetails)\(contact) </br></br>  Please find the below download url!</br></br> <a href=\"\(self.downloadURL!)\">\(click)</a></p>"
            }
            else{
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br> Details: \(strDetails)\(contact) </br> </br> Please find the below attached file.</br></br></p>"
            }
            builder.htmlBody = msg
            
        }else{
            builder.header.to = [MCOAddress(displayName: "Consulting Mastery", mailbox:CALL_BACK_MAIL)]
            builder.header.from = MCOAddress(displayName: "GICM App", mailbox: MAIL_USERNAME)
            builder.header.subject = "GICM Call4Backup request"
            let click = "Click here to download"
            var msg = ""
            //   var dataDcos:Data?
            let contact = "</br>Requestor: \(UserDefaults.standard.getUserName())</br>Contact: \(UserDefaults.standard.getEmail())</br>"
            if downloadURL == nil{
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br> Mode: \(strMode) </br> Details: \(strDetails)\(contact)</br></br></p>"
            }
            else if fileSize > CALL_BACK_MAIL_MAX_SIZE {
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br> Mode: \(strMode) </br>  Details: \(strDetails)\(contact) </br></br>  Please find the below download url!</br></br> <a href=\"\(self.downloadURL!)\">\(click)</a></p>"
            }
            else{
                msg = "<p>Hey,</br></br> Type: \(strTitle) </br> Mode: \(strMode) </br> Details: \(strDetails)\(contact) </br> </br> Please find the below attached file.</br></br></p>"
            }
            builder.htmlBody = msg
        }
        
        
        do {
            if fileSize < CALL_BACK_MAIL_MAX_SIZE  {
                
                do {
                    let dirContents = try fileManager.contentsOfDirectory(atPath: strPathDocs)
                    for fileName in dirContents {
                        let attachment = MCOAttachment()
                        attachment.filename = fileName
                        
                        if fileName == "audio.caf"{
                            attachment.mimeType =  "audio/x-caf"
                            attachment.data = try Data(contentsOf: pathDocs!.appendingPathComponent("audio.caf"))
                        }
                        else if fileName == "image.jpg" {
                            attachment.mimeType =  "image/jpg"
                            attachment.data = try Data(contentsOf: pathDocs!.appendingPathComponent("image.jpg"))
                        }
                        else if fileName == "video.mp4"{
                            attachment.mimeType =  "video/mp4"
                            attachment.data = try Data(contentsOf: pathDocs!.appendingPathComponent("video.mp4"))
                        }
                        else{
                            // need to work for document
                            attachment.mimeType =  "application/binary"
                            attachment.data = try Data(contentsOf: docsURL!)
                        }
                        builder.addAttachment(attachment)
                    }
                }catch {
                    print("Unable to attach data: \(error)")
                }
            }
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    
                    DispatchQueue.main.async(execute: {
                        NSLog("Error sending email: \(error.debugDescription)")
                        WebserviceManager.shared.hideMBProgress(view: self.view)
                    })
                    
                } else {
                    NSLog("Successfully sent email!")
                    //                    Utility.sharedInstance.displayFailureAlertWithMessage(message: "Thank you. Your request will be passed to one of our expert advisors who will be in contact as soon as possible", title: "Success") { (showw) in
                    //                    }
                    DispatchQueue.main.async(execute: {
                        self.removeExistFile()
                        self.navigationController?.popViewController(animated: true)
                        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.thank_call4back)!)
                    })
                    WebserviceManager.shared.hideMBProgress(view: self.view)
                }
            }
        } catch (let error) {
            print(error)
            WebserviceManager.shared.hideMBProgress(view: self.view)
        }
    }
    
    func uploadFile(){
        // docId = Utility.sharedInstance.randomString(length: 6)
        let refStorage = Storage.storage().reference().child("call4backup").child("\(pathFolder).zip")
        refStorage.putFile(from: URL(fileURLWithPath: strPathDocsZip), metadata: nil) { (storageData, error) in
            if error == nil {
                refStorage.downloadURL(completion: { (url, error) in
                    if error == nil{
                        self.downloadURL = url
                        print(self.downloadURL ?? "")
                        if self.fromVC == "Contribution"{
                            self.saveRequestContribution()
                        }else{
                            self.saveRequest()
                        }
                    }
                })
            }
        }
    }
    //MARK: UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // Do something
        print(url)
        let fileDoc = pathDocs!.appendingPathComponent("document.\(url.pathExtension)")
        docsURL = fileDoc
        do {
            try  fileManager.copyItem(at: url, to: fileDoc)
            self.btnDocs.isSelected = true
            self.enableBtnSubmit();
            
        } catch {
            print(error)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
        // dismiss(animated: true, completion: nil)
    }
    
}
//MARK: - UIImagePickerControllerDelegate Methods
extension SendCallBackVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func chooseuploadImage(){
        
        let alert = UIAlertController(title: "Scan Documents", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { _ in
            self.openCamera(showVideo: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Document", style: .default, handler: { _ in
            self.openFile()
        }))
        
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        imagePicker.delegate = self
    }
    
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let fileImage = pathDocs!.appendingPathComponent("image.jpg")
            do {
                try imageData?.write(to: fileImage)
                self.btnDocs.isSelected = true
                self.enableBtnSubmit()
                
            } catch {
                print(error)
            }
        }
        else
        {
            guard
                let mediaType = info[UIImagePickerControllerMediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerControllerMediaURL] as? URL,
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                else {
                    return
            }
            let fileVideo = pathDocs!.appendingPathComponent("video.mp4")
            let fileVideoStr = "\(strPathDocs)"+"/video.mp4"
            
            do {
                if fileManager.fileExists(atPath:fileVideoStr){
                    try  fileManager.removeItem(at: fileVideo)
                }
                try  fileManager.copyItem(at: url, to: fileVideo)
                self.enableBtnSubmit()
                if isAttach {
                    self.btnDocs.isSelected = true
                }else{
                    self.btnVideo.isSelected = true
                }
                
            } catch {
                print(error)
            }
            //            UISaveVideoAtPathToSavedPhotosAlbum(
            //                url.path,
            //                self,
            //                #selector(video(_:didFinishSavingWithError:contextInfo:)),
            //                nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        print (message)
    }
    
    //MARK: - OpenCamera
    func openCamera(showVideo:Bool){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            if showVideo{
                imagePicker.videoQuality = .typeMedium
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.videoMaximumDuration = 60.0
                imagePicker.cameraDevice = .front
            }
            else{
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.cameraDevice = .rear
            }
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - OpenGallary
    func openGallary(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeMovie, kUTTypeVideo, kUTTypeMPEG4,kUTTypeImage] as [String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openFile(){
        let types = [(kUTTypeData as String), (kUTTypeContent as String), (kUTTypePDF as String), (kUTTypeText as String), (kUTTypePlainText as String), (kUTTypeXML as String), (kUTTypeJSON as String), (kUTTypeImage as String), (kUTTypeAudiovisualContent as String),(kUTTypeRTF as String),(kUTTypeJavaScript as String)]
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
}





