//
//  InviteContact.swift
//  GICM
//
//  Created by Rafi on 09/10/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI
import FirebaseAuth
import FirebaseDynamicLinks
import Instabug
let App_Id = "718966271"
let App_Version = "1.0"

class InviteContact: UIViewController,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UITextFieldDelegate,CNContactPickerDelegate{
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewInviteSuccess: UIView!
    var arrayContact:[PhoneContactModel] = []
    var arrSearch:[PhoneContactModel] = []
    var arrayPhoneModel:[PhoneNoModel] = []
    var arrayEmailModel:[EmailIDModel] = []
    var email : String?
    var phone : String?
    var cname : String?
    var invite_id  = ""
    var isSearch = true
    typealias isCompleted = (URL) -> ()
    typealias checkInvite = (Bool) -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblContact.tableFooterView = UIView()
        txtSearch.addTarget(self, action: #selector(searchRecordsAsPerText(_ :)), for: .editingChanged)
        
        self.tabBarController?.view.addSubview(viewInviteSuccess)
        viewInviteSuccess.frame = self.view.frame
        viewInviteSuccess.isHidden = true
        
      //  gettingContacts()
    }
    @IBAction func backButtonHandler(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func gettingContacts(){
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey,
            CNContactFamilyNameKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("\(contact.givenName) \(contact.middleName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                    }
                }
            }
            arrayContact.removeAll()
            for contact in contacts {
                arrayPhoneModel.removeAll()
                arrayEmailModel.removeAll()
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        arrayPhoneModel.append(PhoneNoModel(name: label, phoneNo: number.stringValue))
                    }
                }
                
                
                for emailID in contact.emailAddresses {
                    if let id = emailID.value as? String {
                        arrayEmailModel.append(EmailIDModel(name:  emailID.label ?? "", emailID: id))
                    }
                }
                
                arrayContact.append(PhoneContactModel(name: contact.givenName, avatarData:contact.thumbnailImageData  ?? Data() , phoneNumber: arrayPhoneModel, emailID: arrayEmailModel,familyName:contact.familyName))
            }
            
            print(arrayContact)
            self.arrSearch = self.arrayContact
            tblContact.reloadData()
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    @IBAction func inviteSuccessOkHandler(_ sender: Any) {
        viewInviteSuccess.isHidden = true
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Table View Search
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        arrSearch.removeAll()
        if textfield.text?.count != 0 {
            for strModelText: PhoneContactModel in arrayContact {
                let mobileRange = (strModelText.name).lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
                
                if  mobileRange != nil
                {
                    arrSearch.append(strModelText)
                }
            }
        } else {
            arrSearch = arrayContact
        }
        tblContact.reloadData()
    }
    
    
    //MARK:- Local methods
    func sendEmail(email:[String]) {
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
                mailer.setToRecipients(email)
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
        let link = URL(string: "https://gicm.page.link/?invitedby=\(invite_id)")
        let referralLink = DynamicLinkComponents(link: link!, domain: "gicm.page.link")
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.demo.app2018")
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
    
    func sendSMS(phone:[String]) {
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
                controller.recipients = phone
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
        if let emailId = email {
            let refCheck  = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID()).whereField("invitedMail", isEqualTo: emailId)
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
                self.viewInviteSuccess.isHidden = false
            }
        })
    }
    
    func getInviteJson() -> [String:Any]{
        return ["invitedMail" : email ?? "",
                "invitedName" : cname ?? "",
                "invitedBy"  : Auth.auth().currentUser?.uid ?? "",
                "status" : "invite",
                "user_id" : UserDefaults.standard.getUserID(),
                "invite_id" : invite_id,
                "user_name" : UserDefaults.standard.getUserName()
        ]
    }
    
}
extension InviteContact:UITableViewDelegate,UITableViewDataSource{
    
    //MARK:- Tableview Delagate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath) as! LearningTableViewCell
        cell.setupInviteFriends(model: arrSearch[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let optionMenu = UIAlertController(title: "Contacts", message: "Do you want send invite via Email or SMS", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Email", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Email")
            self.arrayEmailModel.removeAll()
            self.arrayEmailModel = self.arrSearch[indexPath.row].emailID
            self.email =  self.arrayEmailModel.map({$0.emailID}).first
            self.cname = self.arrSearch[indexPath.row].name
            self.checkInvite(isComplete: { (isInvite) in
                if isInvite {
                    self.sendEmail(email: self.arrayEmailModel.map({$0.emailID}))
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: "SMS", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("SMS")
            self.arrayPhoneModel.removeAll()
            self.arrayPhoneModel = self.arrSearch[indexPath.row].phoneNumber
            self.email =  self.arrayPhoneModel.map({$0.phoneNo}).first
            self.cname = self.arrSearch[indexPath.row].name
            self.checkInvite(isComplete: { (isInvite) in
                if isInvite {
                    self.sendSMS(phone: self.arrayPhoneModel.map({$0.phoneNo}))
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
}

