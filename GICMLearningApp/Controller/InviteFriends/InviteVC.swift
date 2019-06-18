//
//  InviteVC.swift
//  GICM
//
//  Created by Rafi on 18/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug
import ContactsUI
import MessageUI
import FirebaseAuth
import FirebaseDynamicLinks

class InviteVC: UIViewController,CNContactPickerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate{
    //MARK:- Initialization
    @IBOutlet weak var lblGetAmoiunt: UILabel!
    @IBOutlet weak var btnPending: UIButton!
    @IBOutlet weak var btnEarning: UIButton!
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    
    var contactSelected : CNContact?
    typealias isCompleted = (URL) -> ()
    typealias checkInvite = (Bool) -> ()
    var email : NSString = ""
    var phone : String = ""
    var cname : String = ""
    var invite_id  = ""

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSLog("***********************************************")
        NSLog(" Invite View Controller View did load  ")
        
        createCustomCommentInstance()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getInvitesEarned()
        getInvites()
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "pending_invite") {
            let vc = segue.destination as! YourInviteVC
            vc.strInvite = "invite"
        }
        else if (segue.identifier == "earned_invite") {
            let vc = segue.destination as! YourInviteVC
            vc.strInvite = "earn"
        }
    }
    
    func getInvites(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID()).whereField("status", isEqualTo: "invite")
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                    self.btnPending.setTitle("\(snap.count)", for: UIControlState.normal)
            }
        })
    }
    func getInvitesEarned(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID()).whereField("status", isEqualTo: "earn")
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                    self.btnEarning.setTitle("\(snap.count * 15) $", for: UIControlState.normal)
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension InviteVC: CommentDelegates{
    //MARK:- CommentDelegates
    func createCustomCommentInstance()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = storyboard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "InviteFriends"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    @IBAction func showInvite(id:UIButton){
        
        switch (CNContactStore.authorizationStatus(for: CNEntityType.contacts)) {
        case CNAuthorizationStatus.authorized:
            print("Permission granted")
            self.navigateContact()
        case CNAuthorizationStatus.denied:
            print("Pemission denied")
            self.showRequestError()
        case CNAuthorizationStatus.notDetermined:
            print("Pemission denied")
            let addressBookStore = CNContactStore()
            addressBookStore.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
               if !isGranted
               {
                self.showRequestError()
               }else{
                self.navigateContact()
                }
            }
        default: break
        }
    }
    @IBAction func shareButtonHandler(id:UIButton){
        self.generateLink { (url) in
            let subject = (url.absoluteString)
            let vc = UIActivityViewController(activityItems: [subject], applicationActivities: [])
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func copyButtonHandler(id:UIButton){
        self.generateLink { (url) in
            let subject = (url.absoluteString)
            UIPasteboard.general.string = subject
            Utilities.sharedInstance.showToast(message: "Copied")
        }
    }
    
    func showRequestError(){
        Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention", message: "Please allow the contact access to invite", controller: self) { (dismiss) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
            })
        }
    }
    
    func navigateContact()
    {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactNicknameKey
                ,CNContactEmailAddressesKey]
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true) {
            self.contactSelected = contact
            print("value:\(String(describing: self.contactSelected))")
            if let mail = self.contactSelected?.emailAddresses.first?.value  {
                self.email = mail
            }
            if let pho = (self.contactSelected?.phoneNumbers.first?.value)?.stringValue  {
                self.phone = pho
            }
            if let name = self.contactSelected?.givenName {
                self.cname = name
            }
            self.showAlert()
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
        }
    }
    func showAlert()
    {
        let optionMenu = UIAlertController(title: "Send to:", message: nil, preferredStyle: .actionSheet)
        if email.length > 0 {
            let saveAction = UIAlertAction(title: email as String, style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Email")
            self.checkInvite(isComplete: { (isInvite) in
                if isInvite {
                    self.sendEmail(email:self.email)
                }
            })
        })
            optionMenu.addAction(saveAction)
       }
        if phone.count > 0 {
        let deleteAction = UIAlertAction(title: phone, style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("SMS")
            self.checkInvite(isComplete: { (isInvite) in
                if isInvite {
                    self.sendSMS(phone: self.phone)
                }
            })
        })
            optionMenu.addAction(deleteAction)

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func commentAnonymous() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "InviteFriends"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
    
    //MARK:- Local methods
    func sendEmail(email:NSString) {
        if UserDefaults.standard.isLoggedIn(){
            self.generateLink { (url) in
                let referrerName = UserDefaults.standard.getUserName()
                let subject = "\(referrerName) invited you to join GICM!"
                let invitationLink = url.absoluteString
                let msg = "<p>Hey,</br>Join me at GICM. Try it and see how easy consulting can be!</br></br> <a href=\"\(invitationLink)\">\(subject)</a></p>"
                if !MFMailComposeViewController.canSendMail() {
                    // Device can't send email
                    return
                }
                let mailer = MFMailComposeViewController()
                mailer.mailComposeDelegate = self
                mailer.setSubject(subject)
                mailer.setMessageBody(msg, isHTML: true)
                mailer.setToRecipients([email as String])
                self.present(mailer, animated: true, completion: nil)
            }
        }
        else{
            Utility.sharedInstance.displayFailureAlertWithMessage(message: "Please login to invite friends", title: "Alert") { (val) in
            }
        }
    }
    
    func generateLink(isComplete:@escaping isCompleted){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        invite_id = "\(uid)_\(Utility.sharedInstance.randomString(length: 5))"
        let link = URL(string: "https://gicmdemo.page.link/?invitedby=\(invite_id)")
        let referralLink = DynamicLinkComponents(link: link!, domain: "gicmdemo.page.link")
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "institute.consultingmastery.meetingmanager")
        referralLink.iOSParameters?.minimumAppVersion = App_Version
        referralLink.iOSParameters?.appStoreID = App_Id
        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
                print(shortURL!)
                isComplete(shortURL!)
            }
        }
    }
    
    func sendSMS(phone:String) {
        if UserDefaults.standard.isLoggedIn(){
            self.generateLink { (url) in
                let referrerName = UserDefaults.standard.getUserName()
                let subject = "\(referrerName) already uses GICM and thinks you would like it too! Try it with your personal invite below! \n \(referrerName) invited you to join GICM -  \(url.absoluteString)"
                if !MFMessageComposeViewController.canSendText() {
                    // Device can't send email
                    return
                }
                let controller = MFMessageComposeViewController()
                controller.body = subject
                controller.recipients = [phone]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        else{
            Utility.sharedInstance.displayFailureAlertWithMessage(message: "Please login to invite friends", title: "Alert") { (val) in
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        controller.dismiss(animated: true)
        if result == .sent{
            self.updateInvite()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent{
            self.updateInvite()
        }
    }
    
    func checkInvite(isComplete:@escaping checkInvite) {
        if email.length > 0 {
            let refCheck  = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID()).whereField("invitedMail", isEqualTo: email)
            refCheck?.getDocuments(completion: { (snapshot, error) in
                if let snap = snapshot?.documents, snap.count > 0{
                    isComplete(false)
                    Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.already_invite)!)
                }
                else{
                    isComplete(true)
                }
            })
        }
        else{
            isComplete(true)
        }
    }
    
    func updateInvite(){
        
        let ref  = FirebaseManager.shared.firebaseDP?.collection("invite")
        ref?.addDocument(data: self.getInviteJson(), completion: { (error) in
            if error == nil{
                Utilities.sharedInstance.showToast(message: FirebaseManager.shared.toastMsgs.update_invite!)
            }
        })
    }
    
    func getInviteJson() -> [String:Any]{
        return ["invitedMail" : email ,
                "invitedName" : cname ,
                "invitedBy"  : Auth.auth().currentUser?.uid ?? "",
                "status" : "invite",
                "user_id" : UserDefaults.standard.getUserID(),
                "invite_id" : invite_id,
                "user_name" : UserDefaults.standard.getUserName()
        ]
    }
}

