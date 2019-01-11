//
//  call4BackupVC.swift
//  GICM
//
//  Created by Rafi on 19/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug

class call4BackupVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tblCallBackUp: UITableView!

    var arrRemoteImage = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "REMOTE Interview practice"),#imageLiteral(resourceName: "REMOTE RFP response"),#imageLiteral(resourceName: "REMOTE Ask the expert"),#imageLiteral(resourceName: "REMOTE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition")]
    var arrClientImage = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review")]
    var arrCall4BackUpText = ["Personal coaching","Interview practice","Proposal support","Expert support","Deliverable review","Team addition"]
    
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomCommentInstance()
        // Do any additional setup after loading the view.
//        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
//        Utility.sharedInstance.isShowMenu = false
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        Utility.sharedInstance.isShowMenu = true
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callBackType(_ sender: Any) {
        let index = (sender as AnyObject).selectedSegmentIndex
        switch index {
        case 0:
            print("Remote")
            let arr = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "REMOTE Interview practice"),#imageLiteral(resourceName: "REMOTE RFP response"),#imageLiteral(resourceName: "REMOTE Ask the expert"),#imageLiteral(resourceName: "REMOTE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition")]
            arrRemoteImage = arr
            tblCallBackUp.reloadData()
        case 1:
            print("Onsite")
            let arr = [#imageLiteral(resourceName: "Personal coaching"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review"),#imageLiteral(resourceName: "REMOTE Team addition"),#imageLiteral(resourceName: "ONSITE Team addition"),#imageLiteral(resourceName: "ONSITE Delivery Review")]
            arrRemoteImage = arr
            tblCallBackUp.reloadData()
        default:
            break
        }
    }
    
    //MARK:- Comment
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
        //addCustomComment()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRemoteImage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callbackup", for: indexPath) as! CallBackUpCell
        cell.selectionStyle = .none
        cell.imgIcon.image = arrRemoteImage[indexPath.row]
        if indexPath.row % 2 == 0{
            cell.lblName2.isHidden = true
            cell.lblName.isHidden = false
            cell.lblName.textAlignment = .left
            cell.lblName.text = arrCall4BackUpText[indexPath.row]
        }else{
            cell.lblName.isHidden = true
            cell.lblName2.isHidden = false
            cell.lblName2.textAlignment = .right
            cell.lblName2.text = arrCall4BackUpText[indexPath.row]
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
        if UserDefaults.standard.isLoggedIn(){
            nextVC.strTitle = arrCall4BackUpText[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else
        {
            Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.update_mail)!)
        }
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblCallBackUp.frame.height/6
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblCallBackUp.frame.height/6
    }
}

extension call4BackupVC: CommentDelegates{
    func createCustomCommentInstance()
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = storyBoard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
        customCommentObj.delegate = self
    }
    
    //Add
    func addCustomComment() {
        self.view.addSubview(customCommentObj.view)
    }
    
    func removeCustomComment()
    {
        if customCommentObj != nil
        {
            customCommentObj.view.removeFromSuperview()
        }
    }
    
    func commentMe() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Call4BackUp"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Call4BackUp"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}

