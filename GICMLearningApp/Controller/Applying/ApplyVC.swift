//
//  ApplyVC.swift
//  GICM
//
//  Created by CIPL on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug
import SwipeCellKit

class ApplyVC: UIViewController {
    
    //MARK:- View Life Cycle
    @IBOutlet weak var tblApply: UITableView!
    @IBOutlet var vwEmail: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    
    var arrTitle = UserDefaults.standard.array(forKey: "ApplyList") as? [String]
    var walletModelObj:walletModel?//["Tracking","Meeting Manager","Capture"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
          // Do any additional setup after loading the view.
          configUI()
        self.getWalletdetails()
        self.vwEmail.frame = self.view.frame
        self.vwEmail.isHidden = true
        self.tabBarController?.view.addSubview(self.vwEmail)
        
      //   self.arrTitle = ["Weekly planner"]//["Tracking","Meeting Manager","Capture","Weekly planner"]
        self.tblApply.reloadData()
       NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableApply), name: Notification.Name("NofifyReloadApply"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTableApply()
    {
       configUI()
      //   self.arrTitle = ["Weekly planner"]//["Tracking","Meeting Manager","Capture","Weekly planner"]
         self.tblApply.reloadData()
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        retractedTabIcon()
//        isTabBarExpanded = false
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        configUI()
        self.resetLeaderBoardTimer()
        self.getWalletdetails()
    }
    
    func resetLeaderBoardTimer(){
        let appde = Constants.appDelegateRef
        appde.timerLeader.invalidate()
        print("Total Timer Value  \(appde.totalLeaderBoardTimerCount)")
        appde.totalLeaderBoardTimerCount = 0
    }
    
    //MARK:- Local methods
    func configUI(){
        self.arrTitle = UserDefaults.standard.array(forKey: "ApplyList") as? [String] ?? ["Meeting Manager"]
        
        if arrTitle?.count == nil || arrTitle?.count == 0{
            self.arrTitle = [String]()
            let arrApplyList = ["Tracking","Weekly planner","Breath reset"]
            UserDefaults.standard.set(arrApplyList, forKey: "ApplyList")
            UserDefaults.standard.synchronize()

            arrTitle? = ["Tracking","Weekly planner","Breath reset"]
            self.tblApply.reloadData()
        }else{
            print("Not Empty")
            self.tblApply.reloadData()
        }
    }
    
    //MARK:- Button Action
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func addTools(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "AddToolsVC") as! AddToolsVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func emailCancel(_ sender: Any) {
        vwEmail.isHidden = true
        self.txtEmail.text = ""
        self.txtEmail.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBAction func saveEmail(_ sender: Any) {
        if (txtEmail.text?.count)! > 0 {
            let  strEmailSwitch = txtEmail.text ?? ""
            
            if !Utilities.sharedInstance.validateEmail(with:strEmailSwitch){
                let errorMessage = Constants.ErrorMessage.vaildemail
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
            }else{
                vwEmail.isHidden = true
                self.txtEmail.text = ""
                self.txtEmail.resignFirstResponder()
                self.view.endEditing(true)
                
                if UserDefaults.standard.getUserName().count == 0{
                    UserDefaults.standard.setUserName(value: "Anonymous")
                }else{
                    
                }
                
                UserDefaults.standard.setEmail(value: strEmailSwitch)
                UserDefaults.standard.synchronize()
                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            //self.switchUserFB();
        }else{
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: Constants.ErrorMessage.email, controller: self)
            //  Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.emailid)!)
        }
    }
    
    
    
}

