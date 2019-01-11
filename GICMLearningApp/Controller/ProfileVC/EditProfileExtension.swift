//
//  EditProfileExtension.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
//MARK: - UIImagePickerControllerDelegate Methods
extension EditProfileViewController{
    func setImageAtLeft(){
        Utilities.sharedInstance.setImageAtLeft(image:"User",textField: txtUserName)
        Utilities.sharedInstance.setImageAtLeft(image:"Email",textField: txtEmail)
        Utilities.sharedInstance.setImageAtLeft(image:"Calendar",textField: txtDOB)
        
        createCustomPickerInstance() // Custom Picker
    }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    
    // MARK: - Validation Methods
    func addCreateValidate() -> Bool {
        
        var bIsSuccess     = false
        var errorMessage   = ""
        let strUserName    = (txtUserName.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        let strEmail       = (txtEmail.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        
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
        if strBase64 == ""{
            strBase64 = UserDefaults.standard.getProfileImage()
        }
        
        let editData = ["user_name" : txtUserName.text ?? "","e_mail"  : txtEmail.text ?? "","dob" : txtDOB.text ?? "","prof_pic" : strBase64] as [String:Any]
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").document(UserDefaults.standard.getUserID())
        ref.updateData(editData, completion: { (error) in
            print("Edit Detail Error: \(String(describing: error))")
            if error == nil{
                self.navigationController?.popViewController(animated: true)
                self.storeUserData()
            }
            else
            {
                  Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
    
    //Store in Locally
    func storeUserData(){
        UserDefaults.standard.setEmail(value: txtEmail.text ?? "")
        UserDefaults.standard.setUserName(value: txtUserName.text ?? "")
        UserDefaults.standard.setDOB(value: txtDOB.text ?? "")
        UserDefaults.standard.setProfileImage(value: strBase64)
        UserDefaults.standard.synchronize()
    }
    
}



//MARK: - UITextFieldDelegate Methods
extension EditProfileViewController : UITextFieldDelegate {
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

//MARK:- CustomPicker Methods
extension EditProfileViewController :CustomPickerDelegate {
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    func dateOfBirthAction(){
        dismissKeyboard()
        selectedPicker = "dob"
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_Date)
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
    }
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}


