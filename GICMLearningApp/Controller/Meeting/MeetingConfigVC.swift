//
//  MeetingConfigVC.swift
//  GICM
//
//  Created by Rafi on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug

class MeetingConfigVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    //MARK:- Initialization
    
    @IBOutlet weak var txtMeetingName: UITextField!
    @IBOutlet weak var txtVwKeyWords: UITextView!
    @IBOutlet weak var lblNoOfSpeakers: UILabel!
    var speakerCount = 2
    @IBOutlet weak var viewFlip: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var sliderBritness: UISlider!

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
//        self.view.addSubview(viewFlip)
//        viewFlip.frame = .init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height-110)
//        viewFlip.isHidden = true
        // Do any additional setup after loading the view.
    NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
    Utility.sharedInstance.isShowMenu = false
    
}
    
override func viewDidDisappear(_ animated: Bool) {
    Utility.sharedInstance.isShowMenu = true
}

    func flipTransition () {
      
        UIView.animate(withDuration: 0.5) {
            self.viewMain.transform = self.viewMain.transform.rotated(by: .pi)
        }
    }
    
    @IBAction func rotateAction(_ sender: Any) {
        self.flipTransition()
        
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     //MARK:- Local Methods
            
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func speakers(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        if currentValue < 2{
        lblNoOfSpeakers.text =  "\(currentValue) speaker"
        }else{
        lblNoOfSpeakers.text =  "\(currentValue) speakers"
        }
        speakerCount = currentValue
    }
    
    @IBAction func brightness(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
        
    }
    
    
    @IBAction func consulting(_ sender: Any) {
    }
    
    @IBAction func start(_ sender: Any) {
        
        let strMeetingName    = txtMeetingName.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        
        if strMeetingName == "" {
            Utilities.displayFailureAlertWithMessage(title:"Attention!", message:Constants.ErrorMessage.meetingName, controller:self)
        }
        else
        {
            let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "MeetingVC") as! MeetingVC
            nextVC.strMeetingName = strMeetingName!
            nextVC.speakerCount = speakerCount
            if txtVwKeyWords.text.count > 0{
                nextVC.stringSpeechContext = txtVwKeyWords.text
            }
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func camera(_ sender: Any) {
        let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CameraOverlayVC") as! CameraOverlayVC
        vc.isMeeting = true
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false,completion: nil)
            
        // vc.imgWhiteBoard.image =
//        if !(self.navigationController?.viewControllers.contains(vc))! {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //MARK:- Delegate Methods
    
    
    
   
}
