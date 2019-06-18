//
//  Utility.swift
//  Find Tyre
//
//  Created by CIPL108-MOBILITY on 20/12/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
//import CNPPopupController

typealias callBack = (Bool) -> Void

class Utility: NSObject {
    
    static let sharedInstance = Utility()

    let controller = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.last
    let window = UIApplication.shared.windows.first!
    var isShowMenu = true
    var isOpenedMenu = false
    //var popUpController = CNPPopupController(contents: [UnifyCustomPopup(frame: .zero)])
    
    func viewControllerWithName(identifier: String) ->UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    //MARK: - USER DEFAULTS
    
    func saveToDefaults(object:String,key:String)  {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - LOG
    
    func log(any : Any) {
        print(any)
    }
    
    //MARK: - Alert
    
    func displayAlertForNoConnection() {
        
        let actionSheet: UIAlertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            
        }
        actionSheet.addAction(cancelActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func displayAlertForServerError(message : String) {
        let actionSheet: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            
        }
        actionSheet.addAction(cancelActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func displayComingSoonAlert() {
        
        let actionSheet: UIAlertController = UIAlertController(title: "Coming soon !", message: "We are working hard to meet your needs. Please hang on", preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            
        }
        actionSheet.addAction(cancelActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func displayAlertWithActionCallBack(message:String,title:String,actionButtonTitle:String, onCompletion: @escaping callBack){
        
        let actionSheet: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            DispatchQueue.main.async {
                onCompletion(false)
            }
        }
        
        let settingsActionButton: UIAlertAction = UIAlertAction(title: actionButtonTitle, style: .default) { action -> Void in
            DispatchQueue.main.async {
                onCompletion(true)
            }
        }
        
        actionSheet.addAction(cancelActionButton)
        actionSheet.addAction(settingsActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func clearAllUserdata(){
        UserDefaults.standard.set("0", forKey: "Login")
         UserDefaults.standard.set("", forKey: "MAIL")
         UserDefaults.standard.set("", forKey: "PSWD")
        UserDefaults.standard.setLoggedIn(value: false)
        UserDefaults.standard.setUserID(value: "0")
        UserDefaults.standard.setUserName(value: "")
        UserDefaults.standard.setEmail(value: "")
        UserDefaults.standard.setDOB(value: "")
        UserDefaults.standard.setProfileImage(value: "")
        UserDefaults.standard.synchronize()
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    //MARK:- Torch
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func displayFailureAlertWithMessage(message:String,title:String, onCompletion: @escaping callBack){
        
        let actionSheet: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            DispatchQueue.main.async {
                onCompletion(true)
            }
        }
        
        actionSheet.addAction(cancelActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func displaySuccessAlertWithMessage(message:String,title:String, onCompletion: @escaping callBack) {
        let actionSheet: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            DispatchQueue.main.async {
                onCompletion(true)
            }
        }
        
        actionSheet.addAction(cancelActionButton)
        
        getCurrentController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Controller
    
    func getCurrentController() -> UIViewController? {
        
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        
        if let presented = rootViewController?.presentedViewController {
            return presented
        }
        else if rootViewController is UINavigationController {
            return (rootViewController as? UINavigationController)?.viewControllers.last
        }
        
        return (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.last
    }
    
    func createMenuButton() -> UIBarButtonItem {
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: nil, action: nil)
        return menuButton
    }
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    func getAudioPermission(){
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
            Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention", message: "Please allow the microphone access to record audio", controller: (Constants.appDelegateRef.window?.rootViewController)!) { (dismiss) in
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                })
            }
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
                if !granted {
                    Utilities.showSuccessFailureAlertWithDismissHandler(title: "Attention", message: "Please allow the microphone access to record audio", controller: (Constants.appDelegateRef.window?.rootViewController)!) { (dismiss) in
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                        })
                    }
                }
            })
        }
    }
    //MARK: - Animation
    
    func shakeWindow() {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: window.center.x - 10, y: window.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: window.center.x + 10, y: window.center.y))
        window.layer.add(animation, forKey: "position")
    }
    
}


// Random Color
extension UIColor {
    
    static var random: UIColor {
        let randomRed:CGFloat = CGFloat(arc4random_uniform(256))
        let randomGreen:CGFloat = CGFloat(arc4random_uniform(256))
        let randomBlue:CGFloat = CGFloat(arc4random_uniform(256))
        let myColor =  UIColor(red: randomRed/255, green: randomGreen/255, blue: randomBlue/255, alpha: 1.0)
        return myColor
    }
}


extension UIButton {
    func underline() {
        let green = UIColor.init(red: 66.0/255.0, green: 166.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        self.titleLabel?.textColor = green
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func removeUnderLine() {
        self.titleLabel?.textColor = UIColor.darkGray
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleNone.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
}
