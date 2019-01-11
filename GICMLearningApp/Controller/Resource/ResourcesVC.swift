//
//  Resources.swift
//  GICMLearningApp
//
//  Created by Rafi on 18/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import LUExpandableTableView
import MessageUI
import FirebaseStorage
import FirebaseFirestore
import SDWebImage
import WebKit
import Instabug

let stringExcelPath = "https://firebasestorage.googleapis.com/v0/b/gicm-mobile-app.appspot.com/o/uploads%2FWorkbook1.xlsx?alt=media&token=99fd178c-a9bb-41f6-870b-41c5b78bdb53"
let CALL_BACK_MAIL_RES = "info@ConsultingMastery.Institute"

class ResourcesVC: UIViewController ,MFMailComposeViewControllerDelegate, WKUIDelegate,WKNavigationDelegate{
    
    @IBOutlet weak var tblExpand: LUExpandableTableView!
    
    var arraySectionTitle:[String] = []
    var arraySubTitle:[String] = []
    var arraySubItalic:[String] = []
    var arrayTop:[String] = []
    var arrayBottom:[String] = []
    var arrayMail:[String] = []
    var arrayResult:[QueryDocumentSnapshot] = []
    
    //    var arrayLeftSide:[UIImage] = [#imageLiteral(resourceName: "thinkCellLogo"),#imageLiteral(resourceName: "expensify"),#imageLiteral(resourceName: "businessCase"),UIImage()]
    var arrayLeftSide : [Data] = []
    var arrayRightSideTop:[UIImage] = [#imageLiteral(resourceName: "websiteLink"),#imageLiteral(resourceName: "appStore"),#imageLiteral(resourceName: "sendEmail"),UIImage()]
    var arrayRightSideBottom:[UIImage] = [UIImage(),#imageLiteral(resourceName: "websiteLink"),UIImage(),UIImage()]
    var arrayDescription:[String] = []
    var arrayHeaderImageState:[Bool] = [true,false,true,false] //Up arrow is for true and down arrow is for false
    var arraySectionCellCount = [1,1,1,0]
    let cellReuseIdentifier = "ResourceDescriptionCell"
    let sectionHeaderReuseIdentifier =  "MySectionHeader"
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    
    @IBOutlet weak var webView: WKWebView!
    let webManager = WebserviceManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomCommentInstance()
        // Do any additional setup after loading the view.
        self.title = "Resources"
        tblExpand.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tblExpand.register(UINib(nibName: "MyExpandableTableViewSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        
        tblExpand.expandableTableViewDelegate = self
        tblExpand.expandableTableViewDataSource = self
        tblExpand.tableFooterView = UIView()
        self.webViewConfig()
        
        self.getResources()
        
    }
    
    func webViewConfig(){
        //webView.isHidden = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
         let refStorage = Storage.storage().reference().child("html").child("resource.html")
        refStorage.downloadURL(completion: {url,error in
           
            if error == nil{
            print("URL \(url)")
                var urlRequest = URLRequest(url: url!)
                urlRequest.cachePolicy = .returnCacheDataElseLoad
                self.webView.load(urlRequest)
                self.webView.allowsBackForwardNavigationGestures = true
            }})
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        webManager.showMBProgress(view: self.view)
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish to load")
        webManager.hideMBProgress(view: self.view)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        let app = UIApplication.shared
        let url = navigationAction.request.url
        print("Access \(String(describing: url?.scheme))")
        webManager.showMBProgress(view: self.view)
        if url?.scheme == "tel"
        {
            let login = UserDefaults.standard.isLoggedIn()
            if login{
                self.configureMail()
                decisionHandler(.cancel)
                return
            }else{
                decisionHandler(.cancel)
                webManager.hideMBProgress(view: self.view)
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Please login to send mail", controller: self)
                return
            }
        }else{
           webManager.hideMBProgress(view: self.view)
             decisionHandler(.allow)
        }
        //        if (url!.scheme == myScheme as String) && app.canOpenURL(url!) {
        //            print("redirect detected..")
        //            // intercepting redirect, do whatever you want
        //            app.openURL(url!) // open the original url
        //            decisionHandler(.cancel)
        //            return
        //        }
       
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
        let emailId = UserDefaults.standard.getEmail()
        builder.header.to = [MCOAddress(displayName: UserDefaults.standard.getUserName(), mailbox: emailId)]//CALL_BACK_MAIL_RES)]
        builder.header.from = MCOAddress(displayName: "GICM App", mailbox: "info@ConsultingMastery.Institute")
        builder.header.subject = "Your GICM resources request"
        var dataDcos:Data?
        
        var userName = UserDefaults.standard.getUserName()
        userName = userName.capitalizingFirstLetter()
        
        let  msg = "<p>Hello \(userName),<br><br> Please find attached your requested resource document.<br><br>Cheers,<br>Your GICM Team</p>"
        do {
            dataDcos = try Data(contentsOf: URL.init(string: stringExcelPath)!)
        } catch {
            print("Unable to load data: \(error)")
        }
        builder.htmlBody = msg
        do {
            if dataDcos != nil {
                let attachment = MCOAttachment()
                attachment.mimeType =  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                attachment.filename = "resource.xlsx"
                attachment.data = dataDcos!
                builder.addAttachment(attachment)
            }
            let rfc822Data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: rfc822Data)
            sendOperation?.start { (error) -> Void in
                if (error != nil) {
                    NSLog("Error sending email: \(error.debugDescription)")
                } else {
                    NSLog("Successfully sent email!")
                  //  Utilities.sharedInstance.showToast(message: "Successfully sent email!")
                    self.webManager.hideMBProgress(view: self.view)
//                    Utilities.showSuccessFailureAlertWithDismissHandler(title: "success!", message: "The file has been send to your registered email.", controller: self, alertDismissed: { (_) in
//                        self.navigationController?.popViewController(animated: true)
//                    })
                    Utilities.sharedInstance.showToast(message: "The file has been send to your registered email.")
                    self.navigationController?.popViewController(animated: true)
                   //
                }
                WebserviceManager.shared.hideMBProgress(view: self.view)
            }
        } catch (let error) {
            print(error)
            WebserviceManager.shared.hideMBProgress(view: self.view)
        }
    }
    //    func getLeftSideIcon(){
    //        arrayLeftSide.removeAll()
    //        for doc in arrayResult{
    //            let refStorage = Storage.storage().reference().child("resource").child("\(doc.documentID).png")
    //            refStorage.getData(maxSize:  100000) { (imagedata, error) in
    //                if error == nil{
    //                    self.arrayLeftSide.append(imagedata as! Data)
    //                    self.tblExpand.reloadData()
    //
    //                }
    //            }
    //        }
    //    }
    
    //decidePolicyForNavigationAction
    
   
    
    func getResources(){
        
        let ref = FirebaseManager.shared.firebaseDP?.collection("resources")
        ref?.getDocuments(completion: { (snapshot, error) in
            self.arrayResult.removeAll()
            if let snap = snapshot?.documents, snap.count > 0{
                self.arrayResult += snap
                
                for obj in snap{
                    self.arraySectionTitle.append(obj.get("title") as? String ?? "")
                    if let subtitle = obj.get("subtitle") as? [String]{
                        self.arraySubTitle += subtitle
                    }
                    else{
                        self.arraySubTitle.append("")
                    }
                    if let subitalic = obj.get("title_italic") as? [String]{
                        self.arraySubItalic += subitalic
                    }
                    else{
                        self.arraySubItalic.append("")
                    }
                    if let desc = obj.get("desc") as? [String]{
                        self.arrayDescription += desc
                    }
                    else{
                        self.arrayDescription.append("")
                    }
                    if let top = obj.get("top") as? [String]{
                        self.arrayTop += top
                    }
                    else{
                        self.arrayTop.append("")
                    }
                    if let bottom = obj.get("bottom") as? [String]{
                        self.arrayBottom += bottom
                    }
                    else{
                        self.arrayBottom.append("")
                    }
                    if let mail = obj.get("mail") as? [String]{
                        self.arrayMail += mail
                    }
                }
                self.tblExpand.reloadData()
                //  self.getLeftSideIcon()
                for i in 0..<2 {
                    if let header = self.tblExpand.tableView(self.tblExpand, viewForHeaderInSection: i) as? MyExpandableTableViewSectionHeader{
                        self.tblExpand.expandableSectionHeader(header, shouldExpandOrCollapseAtSection: i)
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @objc func imageTappedRightSideTop(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        switch tappedImage.tag {
        case 1: //Website
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "WebStoreLinkVC") as! WebStoreLinkVC
            //            vc.strWebsiteLink = "https://www.think-cell.com/en/"
            vc.strWebsiteLink = arrayTop[0]
            //self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: false)
            
        case 2: //Appstore
            if let url = URL(string:arrayTop[1]) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case 3: //Email
            self.sendEmail()
            
        default:
            return
        }
    }
    
    @objc  func imageTappedRightSideDown(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        switch tappedImage.tag {
        case 2: //Website
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "WebStoreLinkVC") as! WebStoreLinkVC
            vc.strWebsiteLink = arrayBottom[1]
            
            //self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: false)
        default:
            return
        }
        // Your action
    }
    func sendEmail() {
        WebserviceManager.shared.showMBProgress(view:self.view)
        self.configureMail()
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
// MARK: - LUExpandableTableViewDataSource

extension ResourcesVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return 3
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ResourceDescriptionCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        
        let section  = indexPath.section
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappedRightSideTop(tapGestureRecognizer:)))
        cell.imgRightSideTop.isUserInteractionEnabled = true
        cell.imgRightSideTop.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizerBottom = UITapGestureRecognizer(target: self, action: #selector(imageTappedRightSideDown(tapGestureRecognizer:)))
        cell.imgRightSideBottom.isUserInteractionEnabled = true
        cell.imgRightSideBottom.addGestureRecognizer(tapGestureRecognizerBottom)
        
        switch section {
        case 0:
            cell.lblSubtitle.text = arraySubTitle[indexPath.row]
            cell.lblsubSubtitle.text = arraySubItalic[indexPath.row]
            //  cell.imgLeftSide.image = UIImage(data: arrayLeftSide[indexPath.row])
            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[indexPath.row].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
            
            cell.imgRightSideTop.image = arrayRightSideTop[indexPath.row]
            cell.imgRightSideBottom.image = arrayRightSideBottom[indexPath.row]
            cell.txtvwDescription.text = arrayDescription[indexPath.row]
            
            if indexPath.row == 0 {
                cell.imgRightSideTop.tag = 1
                cell.imgRightSideBottom.tag = 1
            } else {
                cell.imgRightSideTop.tag = 2
                cell.imgRightSideBottom.tag = 2
            }
            
        case 1:
            cell.lblSubtitle.text = arraySubTitle[2]
            cell.lblsubSubtitle.text = arraySubItalic[2]
            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[2].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
            cell.imgRightSideTop.image = arrayRightSideTop[2]
            cell.imgRightSideBottom.image = arrayRightSideBottom[2]
            cell.txtvwDescription.text = arrayDescription[2]
            cell.imgRightSideTop.tag = 3
            cell.imgRightSideBottom.tag = 3
            
        case 2:
            cell.lblSubtitle.text = arraySubTitle[3]
            cell.lblsubSubtitle.text = arraySubItalic[3]
            cell.imgLeftSide.sd_setImage(with: URL(string: arrayResult[3].get("icon_url") as? String ?? ""), placeholderImage: UIImage(named: "noImage"))
            cell.imgRightSideTop.image = arrayRightSideTop[3]
            cell.imgRightSideBottom.image = arrayRightSideBottom[3]
            cell.txtvwDescription.text = arrayDescription[3]
            cell.imgRightSideTop.tag = 4
            cell.imgRightSideBottom.tag = 4
        default:
            return cell
        }
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as? MyExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        if arraySectionTitle.count > 0{
            sectionHeader.label.text = arraySectionTitle[section]
        }
        return sectionHeader
    }
    
}

// MARK: - LUExpandableTableViewDelegate

extension ResourcesVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        return 170
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        return 33
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select cection header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
    
}


extension ResourcesVC: CommentDelegates{
    func createCustomCommentInstance()
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = mainStoryboard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
        customCommentObj.delegate = self
    }
    
    //Add
    func addCustomComment() {
        self.view.addSubview(customCommentObj.view)
    }
    
    func removeCustomComment()
    {
        if customCommentObj != nil
        {
            customCommentObj.view.removeFromSuperview()
        }
    }
    
    func commentMe() {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Resource"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Resource"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}
