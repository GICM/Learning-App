//
//  CusotmMenu.swift
//  GICM
//
//  Created by Rafi on 26/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CustomMenu: NSObject {
    static let sharedInstance = CustomMenu()
    var viewContainer : UIView?
    var plusDetail : UIView?
    let plusData = ["Leaderboard","Invite Friends","Resources","Reminders","FAQ"]
    let plusDataImg = ["LeaderBoard","friends","resource_blue","bell_blue","FAQ"]
    
    let planeData = ["Invite Friends","Call4Backup","Feedback","FAQ"]
    let planeDataImg = ["friendsInvites","call","feedback","FAQ"]
    let rowHeight:CGFloat = 50
    
    let app = UIApplication.shared.delegate as? AppDelegate
    var isShow = false
    var menuOpen = "plus"
    
    func handleMenu(plus:Bool)
    {
        
        if menuOpen == "plus" && isShow && plus{
            
            self.hideMenu()
        }
        else if menuOpen == "plane" && isShow && !plus {
            self.hideMenu()
        }else{
            self.hideMenu()
            self.showMenu(plus: plus)
        }
        menuOpen = (plus) ? "plus" : "plane"
    }
    
    func showMenu(plus:Bool)
    {
        UserDefaults.standard.set(true, forKey: "isCenterMenuOpened")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("centerMenuOpened"), object: nil, userInfo: nil)
        isShow = true
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let buttomtabBarHeight = (UIApplication.shared.statusBarFrame.height+49) - 20

        viewContainer = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: height-buttomtabBarHeight))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        viewContainer!.addGestureRecognizer(tapGesture)
        let heightDet  = CGFloat(plusData.count) * rowHeight
        let widthDet = ((width / 5) * ((plus) ? 3 : 4) - ((width / 5) / 4)) + 10
        plusDetail = UIView.init(frame: CGRect(x: 0, y: (viewContainer?.frame.size.height)! - heightDet, width: widthDet, height: heightDet))
        plusDetail?.backgroundColor = UIColor.clear
        var y = heightDet
        let count = (plus) ? plusData.count : planeData.count
        for i in 0 ..< count{
            let menuBtn = UIButton.init()
            menuBtn.backgroundColor = UIColor.clear
            menuBtn.tag = i
            if plus{
                menuBtn.addTarget(self, action:
                    #selector(selectedPlusMenuButton(btn:)), for: .touchUpInside)
            }
            else{
                menuBtn.addTarget(self, action:
                    #selector(selectedPlaneButton(btn:)), for: .touchUpInside)
            }
            y = y - rowHeight
            let lbl = UILabel.init(frame: CGRect(x: 0, y: y, width: plusDetail!.frame.size.width-50, height: 50))
            lbl.backgroundColor = UIColor.clear
            lbl.textColor = UIColor.black
            lbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            lbl.textAlignment = .right
            lbl.text = (plus) ? plusData[i] : planeData[i]
            lbl.sizeToFit()
            lbl.frame = CGRect(x: plusDetail!.frame.size.width - lbl.frame.size.width - 50 , y: y+10, width: lbl.frame.size.width, height: 30)
            menuBtn.frame = CGRect(x: lbl.frame.origin.x, y: y, width: lbl.frame.size.width + 50, height: 50)
            
            let imgView = UIImageView.init(image: UIImage.init(named: (plus) ? plusDataImg[i] : planeDataImg[i]))
            imgView.frame = CGRect(x:  plusDetail!.frame.size.width-40, y: y+7, width: 30, height: 30)
            plusDetail!.addSubview(lbl)
            plusDetail!.addSubview(imgView)
            plusDetail!.addSubview(menuBtn)
            self.plusDetail?.clipsToBounds = true
        }
        viewContainer?.addSubview(plusDetail!)
        app?.window?.rootViewController?.view.addSubview(viewContainer!)
        
        self.viewContainer?.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        self.plusDetail?.frame = CGRect(x: 0, y: (self.viewContainer?.frame.size.height)!, width: self.plusDetail!.frame.size.width, height:0 )
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5,options: .curveEaseInOut, animations: {
            self.viewContainer?.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            self.plusDetail?.frame = CGRect(x: 0, y:(self.viewContainer?.frame.size.height)! - heightDet, width: self.plusDetail!.frame.size.width, height:heightDet )
        }) { (completed) in
        }
    }
    
    
    @objc func selectedPlusMenuButton(btn : UIButton) {
        UserDefaults.standard.set(false, forKey: "isCenterMenuOpened")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("centerMenuOpened"), object: nil, userInfo: nil)
        self.hideMenu()
        if btn.tag == 0
        {
         //  Utilities.sharedInstance.showToast(message: "Development in progress")
            let mainStoryboard = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "LeaderBoardVC") as! LeaderBoardVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }else if btn.tag == 1
        {
            let mainStoryboard = UIStoryboard(name: "InviteFriends", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }else if btn.tag == 2
        {
            let story = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "ResourcesVC") as! ResourcesVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }else if btn.tag == 3
        {
            let story = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "RemindersListVC") as! RemindersListVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }else if btn.tag == 4
        {
            let mainStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }
    }
    @objc func selectedPlaneButton(btn : UIButton) {
        self.hideMenu()
        
        if btn.tag == 0
        {
            let mainStoryboard = UIStoryboard(name: "InviteFriends", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
            
        }
        else if btn.tag == 1
        {
            let story = UIStoryboard(name: "CallBackupStoryboard", bundle: nil)
            let nextVC = story.instantiateViewController(withIdentifier: "call4BackupVC") as! call4BackupVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
        }
        else if btn.tag == 2
        {
            //   self.feedbackHanlder()
            NotificationCenter.default.post(name: Notification.Name("NofifyFeedback"), object: nil, userInfo: nil)
            
        }
        else if btn.tag == 3
        {
            //Play books
            let mainStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
            Constants.appDelegateRef.navigationContollerObj.pushViewController(nextVC, animated: true)
            
        }
    }
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        self.hideMenu()
    }
    
    func hideMenu()
    {
        UserDefaults.standard.set(false, forKey: "isCenterMenuOpened")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("centerMenuOpened"), object: nil, userInfo: nil)
        
        viewContainer?.removeFromSuperview()
        plusDetail?.removeFromSuperview()
        isShow = false
        
        
    }
    
}






