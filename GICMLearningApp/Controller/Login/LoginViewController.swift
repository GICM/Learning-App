//
//  LoginViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FBSDKLoginKit
import TwitterKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{

  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  @IBOutlet weak var buttonTwitter: UIButton!
  @IBOutlet weak var btnShowPassword: UIButton!
  @IBOutlet weak var btnFaceBook: FBSDKLoginButton!

    //FaceBook and Twiiter Login
    var name        = ""
    var email       = ""
    var faceBookID  = ""
    var twitterID   = ""
    var profilePic  = ""
    var userId      = ""

  //MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    Utilities.sharedInstance.setImageAtLeft(image:"Password",textField: txtPassword)
    Utilities.sharedInstance.setImageAtLeft(image:"Email",textField: txtEmail)
    
    self.txtEmail.keyboardType = .emailAddress
   // if let accessToken = FBSDKAccessToken.current(){
   //     getFBUserData()
   // }
    
    self.navigationController?.navigationBar.isHidden = true
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
    Utility.sharedInstance.isShowMenu = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       // self.navigationController?.navigationBar.isHidden = false
        Utility.sharedInstance.isShowMenu = true
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated. 
  }
  
    override func viewWillAppear(_ animated: Bool) {
        
        let entered = UserDefaults.standard.bool(forKey: "Entered")
        if entered{
            txtEmail.text = UserDefaults.standard.string(forKey: "MAIL") ?? ""
            txtPassword.text = UserDefaults.standard.string(forKey: "PSWD") ?? ""
        }else{
            txtEmail.text = ""//UserDefaults.standard.string(forKey: "email") ?? ""
            txtPassword.text = ""//UserDefaults.standard.string(forKey: "password") ?? ""
        }
    }
    
  //MARK: - UIButton Action Methods
  @IBAction func buttonBackPressed(_ sender: UIButton) {
    storeLocalData()
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func buttonShowPasswordPressed(_ sender: UIButton) {
    if(sender.tag == 1){
      btnShowPassword.tag = 2
      btnShowPassword.setImage(UIImage.init(named: "Show"), for: UIControlState.normal)
      txtPassword.isSecureTextEntry = true
    }
    else if(sender.tag == 2){
      btnShowPassword.tag = 1
      btnShowPassword.setImage(UIImage.init(named: "Hide"), for: UIControlState.normal)
      txtPassword.isSecureTextEntry = false
    }
  }

    @IBAction func forgotPasswordHandler(_ sender: UIButton) {
        self.showEmailAlert()
    }
    
  @IBAction func buttonLoginPressed(_ sender: UIButton) {
     loginvalidation()
//    var arr = [String]()
//    print(arr[2])
   // abort()
    
  }
  @IBAction func buttonCreatePressed(_ sender: UIButton){
    storeLocalData()
    let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.createVC) as! CreateViewController
    self.navigationController?.pushViewController(vc, animated: true)
  }
    
    @IBAction func faceBookLogin(_ sender: Any) {
       // if Reachability.isConnectedToNetwork() == true {
        
        faceBookLogin()
//        if (FBSDKAccessToken.current()) != nil{
//            getFBUserData()
//        }else{
//            faceBookLogin()
//        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if (error == nil){
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
            // if user cancel the login
            if (result?.isCancelled)!{
                return
            }
            if(fbloginresult.grantedPermissions.contains("email"))
            {
                self.getFBUserData()
                // self.loginFBTWISL()
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        print("Logout")
    }
    
    @IBAction func twitterLogin(_ sender: Any) {
     //   storeLocalData()
//        TWTRTwitter.sharedInstance().logIn(with: self, completion: { (session, error) in
//                        if (session != nil) {
//                            print(session ?? "")
//
//                            print("signed in as \(String(describing: session?.userName))");
//                        } else {
//                            print("error: \(String(describing: error?.localizedDescription))");
//                        }
//                    })
    }
    
}


