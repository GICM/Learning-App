//
//  ApplyVC.swift
//  GICM
//
//  Created by CIPL on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug

class ApplyVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- View Life Cycle
    @IBOutlet weak var tblApply: UITableView!
    
    var arrTitle = UserDefaults.standard.array(forKey: "ApplyList") as? [String] //["Tracking","Meeting Manager","Capture"]
    //var arrImage = [#imageLiteral(resourceName: "Tracking"),#imageLiteral(resourceName: "Meeting"),#imageLiteral(resourceName: "Capture")]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableApply), name: Notification.Name("NofifyReloadApply"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTableApply()
    {
        tblApply.reloadData()
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        retractedTabIcon()
//        isTabBarExpanded = false
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        configUI()
    }
    
    func configUI(){
        self.arrTitle = UserDefaults.standard.array(forKey: "ApplyList") as? [String]
        self.tblApply.reloadData()
        print(arrTitle?.count)
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
    
    //MARK:- Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrTitle?.count)
        return arrTitle!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyCell", for: indexPath) as! ApplyCell
        cell.selectionStyle = .none
        
        let strTilte = self.arrTitle![indexPath.row]
        cell.imgView.image = UIImage(named: strTilte)//arrImage[indexPath.row]
        if indexPath.row % 2 == 0{
            cell.lblLeftType.text = strTilte
            cell.lblRightType.isHidden = true
        }else{
            cell.lblRightType.text = strTilte
            cell.lblLeftType.isHidden = true
        }
        if strTilte == "Meeting Manager" || strTilte == "Capture"
        {
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            if ((loginValue == "0") || (ReachabilityManager.isConnectedToNetwork() == false))
            {
                cell.contentView.alpha = 0.5
            }else{
                cell.contentView.alpha = 1.0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // ["Tracking","Meeting Manager","Capture"]
        let selected = self.arrTitle![indexPath.row]
        if selected == "Tracking"{
            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if selected == "Meeting Manager"{
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            
            if loginValue == "0"
            {
                self.showLoginAlert()
            }else if(ReachabilityManager.isConnectedToNetwork() == false)
            {
                self.showInternetAlert()
            }
            else{
                print("Meeting")
                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }else if selected == "Capture"{
            
            let loginValue = UserDefaults.standard.string(forKey: "Login")
            
            if loginValue == "0"
            {
                //Show Alert
                self.showLoginAlert()
            }
            else if(ReachabilityManager.isConnectedToNetwork() == false)
            {
                self.showInternetAlert()
            }
            else{
                print("Capture")
                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "CaptureVC") as! CaptureVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
            
        }else{
            self.showLoginAlert()
        }
//        if indexPath.row == 0{
//            print("Tracking")
//
////            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
////            let nextVC = story.instantiateViewController(withIdentifier: "ApplyingListVC") as! ApplyingListVC
////            self.navigationController?.pushViewController(nextVC, animated: true)
////
//            let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
//            let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
//            self.navigationController?.pushViewController(nextVC, animated: true)
//
//        }else if indexPath.row == 1{
//            let loginValue = UserDefaults.standard.string(forKey: "Login")
//
//            if loginValue == "0"{
//                //Show Alert
//                self.showLoginAlert()
//            }else{
//            print("Meeting")
//            let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
//            let nextVC = story.instantiateViewController(withIdentifier: "MeetingConfigVC") as! MeetingConfigVC
//            self.navigationController?.pushViewController(nextVC, animated: true)
//            }
//        }else{
//
//            let loginValue = UserDefaults.standard.string(forKey: "Login")
//
//            if loginValue == "0"{
//                //Show Alert
//                self.showLoginAlert()
//            }else{
//                print("Capture")
//                let story = UIStoryboard(name: "CaptureMeeting", bundle: nil)
//                let nextVC = story.instantiateViewController(withIdentifier: "CaptureVC") as! CaptureVC
//                self.navigationController?.pushViewController(nextVC, animated: true)
//            }
//
//
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func showLoginAlert() {
//        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString(" Please login to access Meeting manager and capture features", comment:""), preferredStyle: .alert)
//
//        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
//            Constants.appDelegateRef.requesetAutoLogoutProcess()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
//        }
//        alertController.addAction(OKAction)
//        alertController.addAction(cancelAction)
//        self.navigationController?.present(alertController, animated: true, completion:nil)
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.update_mail)!)

    }
    func showInternetAlert() {
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.connect)!)
        
    }

}
