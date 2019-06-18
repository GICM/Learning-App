//
//  CreateViewModel.swift
//  GICMLearningApp
//
//  Created by Rafi on 29/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

extension CreateViewController{
    
    func setImageAtLeft(){
        Utilities.sharedInstance.setImageAtLeft(image:"User",textField: txtUserName)
        Utilities.sharedInstance.setImageAtLeft(image:"Email",textField: txtEmail)
        Utilities.sharedInstance.setImageAtLeft(image:"Password",textField: txtPassword)
        Utilities.sharedInstance.setImageAtLeft(image:"Password",textField: txtCnfPassword)
        Utilities.sharedInstance.setImageAtLeft(image:"Calendar",textField: txtDOB)
        
        createCustomPickerInstance() // Custom Picker
    }
    
    //MARK: - SignINJSON
    func getSignINJSON() -> [String:Any]{
        return ["user_name" : txtUserName.text ?? "","e_mail"  : txtEmail.text ?? "","password" : txtPassword.text ?? "","dob" : txtDOB.text ?? "","prof_pic" : strBase64]
    }
    
  
    
    //MARK: - RegisterISL
    func requestRegisterFirebase(){
 
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo:  txtEmail.text!)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
               Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "User already exist, try some other", controller: self)
            }
            else
            {
                _ = FirebaseManager.shared.firebaseDP!.collection("users").addDocument(data: self.getSignINJSON(), completion: { (err) in
                    if err  != nil{
                        print("User sign up Error: \(String(describing: err?.localizedDescription))")
                        Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Register Failed, try agian later", controller: self)
                    }
                    else
                    {
                        let firebaseAuth = Auth.auth()
                        firebaseAuth.createUser(withEmail: self.txtEmail.text!, password: self.txtPassword.text!, completion: { (authData, error) in
                            if error == nil{
                                print ("Auth User done")}
                        })
                        print ("User sign up Success")
                        UserDefaults.standard.set(self.txtEmail.text!, forKey: "email")
                        UserDefaults.standard.set(self.txtPassword.text!, forKey: "password")
                        
                        UserDefaults.standard.set("", forKey: "MAIL")
                        UserDefaults.standard.set("", forKey: "PSWD")
                        UserDefaults.standard.set(false, forKey: "Entered")
                        UserDefaults.standard.synchronize()
                      
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    // MARK: - Validation Methods
    func addCreateValidate() -> Bool {
        
        var bIsSuccess     = false
        var errorMessage   = ""
        let strUserName    = (txtUserName.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        let strEmail       = (txtEmail.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        let strPassword    = (txtPassword.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        let strCnfPassword = (txtCnfPassword.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        
        if strUserName == ""{
            errorMessage = Constants.ErrorMessage.usermame
        }
        else if strEmail == "" {
            errorMessage = Constants.ErrorMessage.email
            
        }else if !Utilities.sharedInstance.validateEmail(with:strEmail){
            errorMessage = Constants.ErrorMessage.vaildemail
            
        }else if strPassword == ""{
            errorMessage = Constants.ErrorMessage.password
            
        }else if strCnfPassword == ""{
            errorMessage = Constants.ErrorMessage.cnfPassword
        }
        else if strPassword.count < 6 {
            errorMessage = "Password should be greater than 6 characters"
        }
        else if strPassword != strCnfPassword{
            errorMessage = Constants.ErrorMessage.samePassword
        }else{
            bIsSuccess = true
        }
        
        if !bIsSuccess {
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
        }
        return bIsSuccess
    }
    
}
//MARK: - UITextFieldDelegate Methods
extension CreateViewController : UITextFieldDelegate {
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
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == txtPassword || textField == txtCnfPassword {
//            if (textField.text?.count)! < 7{
//                       Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Password length should be greater than 6", controller: self)
//                textField.text = ""
//            }
//        }
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtDOB {
            self.dateOfBirthAction()
            return false
        }
        return true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
//MARK: - UIImagePickerControllerDelegate Methods
extension CreateViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
        
        picker.dismiss(animated: true, completion: nil)
        //You will get cropped image here..
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imgProfilePhoto.image = image
            imgProfilePhoto.layer.cornerRadius = 70
            imgProfilePhoto.clipsToBounds      = true
            
            let imageData: Data! = UIImageJPEGRepresentation(imgProfilePhoto.image!, 0.2)
            strBase64 = imageData.base64EncodedString()
            
        }else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
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
}

//MARK:- CustomPicker Methods
extension CreateViewController :CustomPickerDelegate {
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    func dateOfBirthAction(){
        dismissKeyboard()
        selectedPicker = "dob"
        addCustomPicker()
        
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_Date)
       // let currentDate: Date = Date()
//        let timeAsString : String = String(babyDate.characters.prefix(10))
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let date12: Date? = dateFormatter.date(from: timeAsString)
//        if let aDate = date12
//        {
//            self.customPickerObj.customDatePicker.maximumDate = aDate
//        }
        
        customPickerObj.customDatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        customPickerObj.customDatePicker.datePickerMode = .date

        
    }
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
        self.customPickerObj.vwBaseView.frame.size.height = self.view.frame.size.height
        self.customPickerObj.vwBaseView.frame.size.width = self.view.frame.size.width
    }
    
    func removeCustomPicker(){
        if customPickerObj != nil{
            customPickerObj.view.removeFromSuperview()
        }
    }
    func itemPicked(item: AnyObject) {
        removeCustomPicker()
        if selectedPicker == "dob"{
            let pickerDateValue = item as! Date
            let dateFormatObj = DateFormatter()
            dateFormatObj.dateFormat = "dd/MM/yyyy"
            dateFormatObj.locale = Locale(identifier: "en-US")
            let strDate =  dateFormatObj.string(from: pickerDateValue)
            txtDOB.text = strDate
        }
        selectedPicker = ""
        isCustomPickerChossed = false
    }
    func pickerCancelled(){
        isCustomPickerChossed = false
        removeCustomPicker()
        selectedPicker = ""
    }
}

