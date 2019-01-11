//
//  UserDefaults.swift
//  IMS
//
//  Created by Rafi on 19/04/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation

extension UserDefaults{
  
  //MARK: Check Login
  func setLoggedIn(value: Bool) {
    set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    //synchronize()
  }
  
  func isLoggedIn()-> Bool {
    return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
  }
  
  //MARK: Save User ID
  func setUserID(value: String){
    set(value, forKey: UserDefaultsKeys.userID.rawValue)
    //synchronize()
  }
  
  //MARK: Retrieve User ID
  func getUserID() -> String{
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    if ((UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) == nil) ||  (UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) == "0")){
        return (appDel.userUUID) ?? ""
    }
    else{
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue)!
    }
  }
  
  //MARK: Save UserName
  func setUserName(value: String){
    set(value, forKey: UserDefaultsKeys.userName.rawValue)
  }
  
    
    
  //MARK: Retrieve UserName
  func getUserName() ->String{
    return UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) ?? ""
  }
  
    //MARK: Save UserName
    func setUserUUID(value: String){
        set(value, forKey: UserDefaultsKeys.userUUID.rawValue)
    }
    
    
    
    //MARK: Retrieve UserName
    func getUserUUID() ->String{
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.userUUID.rawValue) ?? ""
    }
    
    //MARK: Save Email
    func setEmail(value: String){
        set(value, forKey: UserDefaultsKeys.email.rawValue)
    }
    
    //MARK: Save DOB
    func setDOB(value: String){
        set(value, forKey: UserDefaultsKeys.dob.rawValue)
    }
    
    
    //MARK: Retrieve UserName
    func getDOB() ->String{
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.dob.rawValue) ?? ""
    }
    
    //MARK: Retrieve UserName
    func getEmail() ->String{
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.email.rawValue) ?? ""
    }
  
   
    
  //MARK: Save ProfileImage
  func setProfileImage(value: String){
    set(value, forKey: UserDefaultsKeys.profilImage.rawValue)
    //synchronize()
  }
  
  //MARK: Retrieve User ID
  func getProfileImage() -> String{
    return UserDefaults.standard.string(forKey: UserDefaultsKeys.profilImage.rawValue) ?? ""
  }
  
}

