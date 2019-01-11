//
//  LoginViewModel.swift
//  GICMLearningApp
//
//  Created by Rafi on 29/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

var dictLoginmodel = LoginModel()

extension LoginViewController {
    
    public func loginvalidation(){
        
        let strEmail    = txtEmail.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let strPassword = txtPassword.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        
        if strEmail == "" {
            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:Constants.ErrorMessage.email, controller:self)
            
        }else if !Utilities.sharedInstance.validateEmail(with:strEmail!){
            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:Constants.ErrorMessage.vaildemail, controller:self)
            
        }else if strPassword == ""{
            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:Constants.ErrorMessage.password, controller:self)
            
        }else{
            dismissKeyboard()
            
            if ReachabilityManager.isConnectedToNetwork(){
                loginFirebase()
                // modelLoginISL()
            }else{
                Utilities.displayFailureAlertWithMessage(title:"Attention!", message:"Please connect to internet to login" , controller:self)
               
            }
        }
    }
    
    
    //MARK: - RegisterISL
    func loginFirebase(){
        let firebaseAuth = Auth.auth()
        firebaseAuth.signIn(withEmail: self.txtEmail.text!, password: self.txtPassword.text!) { (authData, error) in
            
            if error == nil
            {
                _ = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: self.txtEmail.text!).addSnapshotListener({ (snapshot, error) in
                    if let snap = snapshot?.documents {
                        if snap.count > 0
                        {
                            UserDefaults.standard.setLoggedIn(value: true)
                            UserDefaults.standard.setUserName(value: snap[0].get("user_name") as? String ?? "")
                            UserDefaults.standard.setProfileImage(value: snap[0].get("prof_pic") as? String ?? "")
                            UserDefaults.standard.setEmail(value: snap[0].get("e_mail") as? String ?? "")
                            UserDefaults.standard.setDOB(value: snap[0].get("dob") as? String ?? "")
                            UserDefaults.standard.setUserID(value: snap[0].documentID)
                            
                            UserDefaults.standard.set("1", forKey: "Login")
                            UserDefaults.standard.synchronize()
                            
                            let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                        else
                        {
                            print("User Logine Error: \(String(describing: error?.localizedDescription))")
                            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:"Login Failed, check your username and password" , controller:self)
                        }
                        
                    }
                    else
                    {
                        print("User Logine Error: \(String(describing: error?.localizedDescription))")
                        Utilities.displayFailureAlertWithMessage(title:"Attention!", message:"Login Failed, check your username and password" , controller:self)
                    }
                })
            }
            else
            {
                print("Auth Logine Error: \(String(describing: error?.localizedDescription))")
                Utilities.displayFailureAlertWithMessage(title:"Attention!", message:"Login Failed, check your username and password" , controller:self)
            }
        }
    }
    //MARK: - SignINJSON
    func getFBTWSignINJSON() -> [String:Any]{
        return ["e_mail" : email,
                "user_name"  : name,
                "fb_id"  : faceBookID,
                "twitter_id"  : twitterID,
                "prof_pic"  : profilePic
        ]
    }
    
    
    func loginFBTWISLFirebase()
    {
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: email)
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.navigateHome(snap: snap)
            }
            else
            {
                _ = FirebaseManager.shared.firebaseDP!.collection("users").addDocument(data: self.getFBTWSignINJSON(), completion: { (err) in
                    if err  != nil{
                        print("User sign up Error: \(String(describing: err?.localizedDescription))")
                        Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Register Failed, try agian later", controller: self)
                    }
                    else
                    {
                        print ("User sign up Success")
                        
                        let ref = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: self.email)
                        ref.getDocuments { (snapshot, error) in
                            if let snap = snapshot?.documents, snap.count > 0 {
                                
                                self.navigateHome(snap: snap)
                            }}
                    }
                })
            }
        }
    }
    
    func navigateHome(snap:[QueryDocumentSnapshot])
    {
        UserDefaults.standard.setLoggedIn(value: true)
        UserDefaults.standard.setUserName(value: snap[0].get("user_name") as? String ?? "")
        UserDefaults.standard.setProfileImage(value: snap[0].get("prof_pic") as? String ?? "")
        UserDefaults.standard.setEmail(value: snap[0].get("e_mail") as? String ?? "")
        UserDefaults.standard.setDOB(value: snap[0].get("dob") as? String ?? "")
        UserDefaults.standard.setUserID(value: snap[0].documentID)
        
        UserDefaults.standard.set("1", forKey: "Login")
        UserDefaults.standard.synchronize()
        
        self.clearAllLocalData()
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func storeLocalData(){
        if !(txtEmail.text?.isEmpty)! || !((txtEmail.text?.isEmpty)!){
            UserDefaults.standard.set(txtEmail.text, forKey: "MAIL")
            UserDefaults.standard.set(txtPassword.text, forKey: "PSWD")
            UserDefaults.standard.set(true, forKey: "Entered")
            UserDefaults.standard.synchronize()
        }else{
            print("Not Empty")
        }
    }
    
    //Facebook Login
    func faceBookLogin(){
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                    // self.loginFBTWISL()
                }
            }
        }
    }
    
    //Clear
    func clearAllLocalData(){
        UserDefaults.standard.set("", forKey: "MAIL")
        UserDefaults.standard.set("", forKey: "PSWD")
        UserDefaults.standard.set(false, forKey: "Entered")
        UserDefaults.standard.synchronize()
    }
    
    //MARK:- Get facebook Data
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result!)
                    let userData = result as! NSDictionary
                    self.email = userData["email"] as! String
                    self.name = userData["first_name"] as! String
                    self.faceBookID = userData["id"] as! String
                    
                    if let picture = userData["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                        //                        self.profilePic = data.base64EncodedString()
                        do {
                            let imageData = try Data(contentsOf: URL(string: url)!)
                            self.profilePic = imageData.base64EncodedString()
                        } catch {
                            print("Unable to load data: \(error)")
                        }
                        print(self.profilePic)
                    }
                    // self.loginFBTWISL()
                    self.loginFBTWISLFirebase()
                }
            })
        }else{
            print("Error")
        }
    }
    
    func showEmailAlert()
    {
        let alert = UIAlertController(title: "Attention", message: "Enter your login email id", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "email id"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let strEmail = alert?.textFields![0].text ?? ""
            var errorMessage = ""
            var bIsSuccess = false
            if strEmail == "" {
                errorMessage = Constants.ErrorMessage.email
                
            }else if !Utilities.sharedInstance.validateEmail(with:strEmail){
                errorMessage = Constants.ErrorMessage.vaildemail
                
            }
            else{
                bIsSuccess = true
            }
            
            if !bIsSuccess {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
            }
            else{
                print("Text field: \(String(describing: strEmail))")
                self.firebaseAuth(mail: strEmail)
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func firebaseAuth(mail:String)
    {
        let firebaseAuth = Auth.auth()
        
        //        firebaseAuth.signIn(withEmail: "Rafi@colanonline.com", password: "colan1234") { (authdata, error) in
        //            if error != nil{
        //                print(error ?? "")
        //            }
        //        }
        
        //        firebaseAuth.currentUser?.sendEmailVerification(completion: { (error) in
        //            if error != nil{
        //                print(error ?? "")
        //            }
        //        })
        
        firebaseAuth.sendPasswordReset(withEmail: mail) { (error) in
            if error != nil{
                print(error ?? "")
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Reset password mail has send your mail id", controller: self)
            }
        }
        
    }
}

//MARK: - UITextFieldDelegate Methods
extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true;
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && string == " ") {
            return false
        }
        return true
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}





