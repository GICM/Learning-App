//
//  ProfileViewModel.swift
//  GICMLearningApp
//
//  Created by CIPL0449 on 21/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import Foundation
import SDWebImage
import Firebase
import FirebaseFirestore
import SwipeCellKit
import Instabug
import MessageUI
import LUExpandableTableView
import ExpyTableView
import IQKeyboardManagerSwift

extension ProfileViewController{
    
    // UI Change
    func viewChangeUIFlow(){
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
        let version = appVersions.init(rawValue: appVersion)
        switch version {
        case .weeklyPlan?:
            self.btnAddProject.isHidden = false
        case .meetingManager?:
            self.btnAddProject.isHidden = true
        case .tracking?:
            self.btnAddProject.isHidden = false
        case .capture?:
            self.btnAddProject.isHidden = true
        default:
            print("Default")
        }
    }
    
    // Navigate , Edit , Deletem Project
    func navigateToEditProjectScreen(index: IndexPath,strActionType : String){
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
        let version = appVersions.init(rawValue: appVersion)
        switch version {
        case .weeklyPlan?:
            editProjectScreen(indexPath: index, action: strActionType, type: "Weekly planner")
        case .meetingManager?:
           Utilities.sharedInstance.showToast(message: "Development in progress")
        case .tracking?:
            editProjectScreen(indexPath: index, action: strActionType, type: "Tracking")
        case .capture?:
            Utilities.sharedInstance.showToast(message: "Development in progress")
        default:
            print("Default")
        }
    }
    
    func editProjectScreen(indexPath: IndexPath, action : String,type: String){
        if action == "edit"{
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC =  story.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
        nextVC.fromVC = "edit"
        nextVC.projectModelObj = self.arrProjectList[indexPath.row - 1]
        self.navigationController?.pushViewController(nextVC, animated: true)
        }else if action == "delete"{
            let projectObj = self.arrProjectList[indexPath.row - 1]
            self.strProjectID = projectObj.project_id!
            self.showDeleteAlert()
        }else{
            if type == "Tracking"{
            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
            let modelObj = arrProjectList[indexPath.row - 1]
            nextVC.projectName     = modelObj.project_name!
            nextVC.projectID       = modelObj.project_id!
            self.navigationController?.pushViewController(nextVC, animated: true)
            }else{
                Utilities.sharedInstance.showToast(message: "Development in progress")
            }
        }
    }
    
    //Add Profhect
    func naviagteToAddProject(){
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.4"
        let version = appVersions.init(rawValue: appVersion)
        switch version {
        case .weeklyPlan?:
            self.projectAdd()
        case .meetingManager?:
            Utilities.sharedInstance.showToast(message: "Development in progress")
        case .tracking?:
            self.projectAdd()
        case .capture?:
            Utilities.sharedInstance.showToast(message: "Development in progress")
        default:
            print("Default")
        }
    }
    
    func projectAdd(){
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

//Profile Image Change
extension ProfileViewController{
    func chnageProfileMenuBarIcon(strength: Int){
        if strength < 25{
            
        }
        if strength >= 25{
            UserDefaults.standard.set(true, forKey: "ProfileIconChanged")
            UserDefaults.standard.set(false, forKey: "ProfileImageFullyChanges")
            UserDefaults.standard.set("25", forKey: "profileIcon")
            UserDefaults.standard.synchronize()
        }
        if strength >= 50{
            UserDefaults.standard.set(true, forKey: "ProfileIconChanged")
            UserDefaults.standard.set(false, forKey: "ProfileImageFullyChanges")
            UserDefaults.standard.set("50", forKey: "profileIcon")
            UserDefaults.standard.synchronize()
        }
        if strength >= 75{
            UserDefaults.standard.set(true, forKey: "ProfileIconChanged")
            UserDefaults.standard.set(false, forKey: "ProfileImageFullyChanges")
            UserDefaults.standard.set("75", forKey: "profileIcon")
            UserDefaults.standard.synchronize()
        }
        if strength == 100{
            UserDefaults.standard.set(true, forKey: "ProfileImageFullyChanges")
            UserDefaults.standard.set(true, forKey: "ProfileIconChanged")
            UserDefaults.standard.set(strBase64, forKey: "profileIcon")
            UserDefaults.standard.synchronize()
        }
        
         NotificationCenter.default.post(name: Notification.Name("changeTabBarImage"), object: nil, userInfo: nil)
    }
}


// Add Work Stream
extension ProfileViewController{
    //MARK:- Edit Project
    func addWorkStreamJSON() -> [String:Any]{
        
        return [
            "workStreamData" : self.currentWorkStramData,
            "goal" : self.strGoalName,
            "excercise": self.excercise,
            "meTime" : self.meTime,
            "sleep" : self.sleep
        ]
    }
    
    func addWorkStreamAPI(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(self.strProjectID)
        ref.updateData(self.addWorkStreamJSON(), completion: { (error) in
            print("Edit project Detail Error: \(String(describing: error))")
            if error == nil{
                //  Utilities.showSuccessFailureAlertWithDismissHandler(title: "success!", message: "Updated Successfully", controller: self, alertDismissed: { (_) in
                print("Updated Successfully")
                self.projectListISLFirebase()
                // })
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
}

// MARK:-  Delegates methods
extension ProfileViewController: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate{
    
    // MARK: - Validation Methods
    func editProfileValidate() -> Bool {
        
        var bIsSuccess     = false
        var errorMessage   = ""
        let strUserName    = self.strUserName
        let strEmail       = self.strEmail
        
        if strUserName == ""{
            errorMessage = Constants.ErrorMessage.usermame
        }
        else if strEmail == "" {
            errorMessage = Constants.ErrorMessage.email
            
        }else if !Utilities.sharedInstance.validateEmail(with:strEmail){
            errorMessage = Constants.ErrorMessage.vaildemail
            
        }else{
            bIsSuccess = true
        }
        
        if !bIsSuccess {
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
        }
        return bIsSuccess
    }
    
    func requestEditFirebase(){
        if self.strBase64 == ""{
            self.strBase64 = UserDefaults.standard.getProfileImage()
        }
        
        let editData = ["user_name" : strUserName,"e_mail"  : strEmail,"dob" : strDOB,"prof_pic" : self.strBase64] as [String:Any]
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").document(UserDefaults.standard.getUserID())
        ref.updateData(editData, completion: { (error) in
            print("Edit Detail Error: \(String(describing: error))")
            if error == nil{
                
                self.storeUserData()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
    
    func sendSignInLink()
    {
        let actionCodeSettings = ActionCodeSettings()
        
        //        guard let link = URL(string: "gicm://a") else { return }
        //        let dynamicLinksDomain = "gicm.page.link"
        //        let linkBuilder = DynamicLinkComponents(link: link, domain: dynamicLinksDomain)
        //        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        //
        //        guard let longDynamicLink = linkBuilder.url else { return }
        //        print("The long URL is: \(longDynamicLink)")
        
        actionCodeSettings.url =  URL(string: "https://gicm-mobile-app.web.app/")
        actionCodeSettings.handleCodeInApp = true
        print(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        Auth.auth().sendSignInLink(toEmail:strEmailSwitch,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    if let error = error {
                                        Utilities.sharedInstance.showToast(message: error.localizedDescription)
                                        return
                                    }
                                    // The link was successfully sent. Inform the user.
                                    // Save the email locally so you don't need to ask the user for it again
                                    // if they open the link on the same device.
                                    UserDefaults.standard.set(self.strEmailSwitch, forKey: "EmailSwitch")
                                    Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.switch_user)!)
                                    
        }
    }
    
    func sendEmail(email:NSString) {
        self.generateLink { (url) in
            let subject = "Verify your email for GICM!"
            let invitationLink = url.absoluteString
            let msg = "<p>Hey,</br>Follow this link to verify your email address. If you didn’t ask to verify this address, you can ignore this email!</br></br> <a href=\"\(invitationLink)\">\(subject)</a></p>"
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
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent{
            
        }
    }
    
    func generateLink(isComplete:@escaping isCompleted){
        
        strEmailSwitch = "colantest@gmail.com"
        
        let link = URL(string: "gicm://\(Utility.sharedInstance.randomString(length: 5))/")
        
        print(link ?? "")
        
        let referralLink = DynamicLinkComponents(link: link!, domain: "gicmdemo.page.link")
        
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID:"institute.consultingmastery.meetingmanager")
        
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
    
    func configureMail(){
        
        let link =  "gicm://\(Utility.sharedInstance.randomString(length: 5))"
        print("The long URL is: \(link)")
        UserDefaults.standard.set(link, forKey: "SwitchLink")
        UserDefaults.standard.set("0", forKey: "SwitchLinkVerify")
        UserDefaults.standard.synchronize()
        
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
        builder.header.to = [MCOAddress(displayName: self.strEmailSwitch, mailbox: self.strEmailSwitch)]
        builder.header.from = MCOAddress(displayName: "noreply@gicm-app.com", mailbox: MAIL_USERNAME)
        let subject = "Verify your email for GICM!"
        builder.header.subject = subject
        let invitationLink = link
        let msg = "<p>Hey,</br>Follow this link to verify your email address. </br></br> <a href=\"\(invitationLink)\">\(subject)</a> </br></br> If you didn’t ask to verify this address, you can ignore this email!</p>"
        builder.htmlBody = msg
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error.debugDescription)")
            } else {
                NSLog("Successfully sent email!")
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.switch_user)!)
                
            }
        }
        
    }
    
    func requestRegisterFirebase(){
        
        let editData = ["e_mail"  : self.strEmailSwitch,"user_uuid" : UserDefaults.standard.getUserUUID()] as [String:Any]
        _ = FirebaseManager.shared.firebaseDP!.collection("users").addDocument(data: editData, completion: { (err) in
            if err  != nil{
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.register_failed)!)
            }
            else
            {
                //  self.loginFirebase()
                self.configureMail()
            }
        })
    }
    //Store in Locally
    func storeUserData(){
        UserDefaults.standard.setEmail(value: strEmail )
        UserDefaults.standard.setUserName(value: strUserName)
        UserDefaults.standard.setDOB(value: strDOB )
        UserDefaults.standard.setProfileImage(value: self.strBase64)
        UserDefaults.standard.set("1", forKey: "Login")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("changeTabBarImage"), object: nil, userInfo: nil)
        self.tblProfile.reloadData()
    }
    
    
    func chooseuploadImage(){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        ImagePicker.delegate = self
    }
    
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //  picker.dismiss(animated: true, completion: nil)
        
        let orinalImage : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: orinalImage, cropMode: .circle)
            imageCropVC.setZoomScale(50.0)
            imageCropVC.delegate = self
            imageCropVC.dataSource = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        
        //You will get cropped image here..
        //        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
        //            self.imgProfilePhoto.image = image
        //            imgProfilePhoto.layer.cornerRadius = 70
        //            imgProfilePhoto.clipsToBounds      = true
        //
        //            let imageData: Data! = UIImageJPEGRepresentation(imgProfilePhoto.image!, 0.2)
        //            strBase64 = imageData.base64EncodedString()
        //
        //        }else{
        //            print("Something went wrong")
        //        }
        //        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - OpenCamera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            
            ImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            ImagePicker.allowsEditing = true
            self.present(ImagePicker, animated: true, completion: nil)
            
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - OpenGallary
    func openGallary(){
        ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        ImagePicker.allowsEditing = true
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    
    func dateOfBirthAction(){
        dismissKeyboard()
        selectedPicker = "dob"
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_Date)
        
        
        let currentDate = Date()
        var components = DateComponents()
        components.day = 0
        let minDate = Calendar.current.date(byAdding: components, to:  Date())!
        customPickerObj.customDatePicker.maximumDate = minDate
        
        
        
        
        customPickerObj.customDatePicker.datePickerMode = .date
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && string == " ") {
            return false;
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag < 3 {
            isEdited = true
        }
        if textField.tag == 2 {
            self.dateOfBirthAction()
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.strUserName = textField.text!
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            
            if loginValue == "0"
            {
                UserDefaults.standard.setUserName(value: self.strUserName)
                UserDefaults.standard.synchronize()
                self.calculateProfileCompleteNess()
            }
        }else if textField.tag == 1{
            self.strEmail = textField.text!
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            
            if loginValue == "0"
            {
                if !Utilities.sharedInstance.validateEmail(with:self.strEmail){
                    let errorMessage = Constants.ErrorMessage.vaildemail
                    Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
                }else{
                    UserDefaults.standard.setEmail(value: self.strEmail)
                    UserDefaults.standard.synchronize()
                    self.calculateProfileCompleteNess()
                }
            }
        }
        self.tblProfile.reloadData()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.strMyGoal = textView.text ?? ""
        self.updateGoal()
        self.tblProfile.reloadData()
    }
}
