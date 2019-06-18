//
//  CapturePDF.swift
//  GICMLearningApp
//
//  Created by Rafi on 10/09/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import MessageUI
import PDFGenerator
import FirebaseStorage

class CapturePDF: UIViewController,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var imgViewCapture: UIImageView!
    @IBOutlet weak var lblTitleType: UILabel!
    @IBOutlet weak var imgViewChart: UIImageView!
    @IBOutlet weak var lblTitleHead: UILabel!
    @IBOutlet weak var btnSednMail: UIButton!
    @IBOutlet weak var scrollPDF: UIScrollView!
    @IBOutlet weak var viewPDF: UIView!
    @IBOutlet weak var chartImgHeightConstant: NSLayoutConstraint!
    var closeBtnClosure : (()->Void)?
    var dataPDF:Data?
    @IBOutlet weak var stackPdfImg: UIStackView!
    let CAPTURE_URL : NSString = "https://gicm-mobile-app.web.app/sendCaptureMail"
    var chartImageFileName = ""
    var takenImageFilename:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mailButtonAction () {
        
        do {
            btnClose.isHidden = true
            btnSednMail.isHidden = true
            dataPDF = try PDFGenerator.generated(by: [scrollPDF])
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }        } catch (let error) {
                print(error)
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
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: UserDefaults.standard.getUserName(), mailbox: UserDefaults.standard.getEmail())]
        builder.header.from = MCOAddress(displayName: "GICM App", mailbox: MAIL_USERNAME)
        builder.header.subject = "GICM Capture Report"
        builder.htmlBody = "Please find the below attached pdf."
        
        do {
            dataPDF = try PDFGenerator.generated(by: [scrollPDF])
            //self.closeButtonAction()
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.suc_mail)!)
            let attachment = MCOAttachment()
            attachment.mimeType =  "application/pdf"
            attachment.filename = "capture.pdf"
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
    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    public func showView(chartImg:UIImage){
        btnClose.isHidden = true
        btnSednMail.isHidden = true
//        lblTitleHead.text = "Title Name as of \(self.getCurrentDate())"
//        lblTitleType.text = "\(UserDefaults.standard.string(forKey: "type_of_capture") ?? "") Capture as of \(self.getCurrentDate())"
//        imgViewChart.image = chartImg
//        if Constants.appDelegateRef.imageFullScreenMeeting.count > 0 {
//            self.addCapturedImages()
//        }
//        else
//        {
//            lblTitleType.isHidden = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//            self.configureMail()
//        })
        self.uploadChartImageFile(image: chartImg)
    }
    func addCapturedImages(){
        var i = 0
        for imgData in Constants.appDelegateRef.imageFullScreenMeeting{
            if i == 0{
                imgViewCapture .image = UIImage.init(data: imgData)
            }else{
                let imgView = UIImageView .init(image:  UIImage.init(data: imgData))
                imgView.contentMode = .scaleAspectFit
                stackPdfImg!.addArrangedSubview(imgView)
            }
            i = i + 1
        }
    }
    @IBAction func closeButtonAction () {
        
        guard let closeAction = closeBtnClosure else {
            return
        }
        closeAction()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["\(UserDefaults.standard.getEmail())"])
        mailComposerVC.setSubject("Capture Report from GICM")
        mailComposerVC.setMessageBody("Please find the below attached pdf", isHTML: false)
        mailComposerVC.addAttachmentData(dataPDF!, mimeType: "application/pdf", fileName: "capture.pdf")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        Utilities.displayFailureAlertWithMessage(title: "Alert", message: "Your device could not send e-mail.  Please check e-mail configuration and try again", controller: self)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        self.backToCaptureList()
        btnClose.isHidden = false
        btnSednMail.isHidden = false
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
    func sendSpeechChartNodeFB(){
        
        WebserviceManager.shared.sendMeetingReport(view: self.view, meetingURL: CAPTURE_URL as String, dictBody: self.getSpeechJson(), Success: { (status) in
            
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
    
    func uploadChartImageFile(image : UIImage){
        WebserviceManager.shared.showMBProgress(view: self.view)
        let data = UIImageJPEGRepresentation(image,0.5)
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
    
    func getSpeechJson() ->  [String:Any]{
        let dict = ["user_id": UserDefaults.standard.getUserID(),
                    "user_name":UserDefaults.standard.getUserName(),
                    "emailId":UserDefaults.standard.getEmail(),
                    "captures":takenImageFilename,
                    "image":chartImageFileName
            ] as [String : Any]
        return dict
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

