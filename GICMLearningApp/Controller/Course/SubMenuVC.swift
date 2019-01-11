//
//  CreatingVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 11/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

var isFirsTimeLoaded = true
class SubMenuVC: UIViewController {
        
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var imgResource: UIImageView!
    @IBOutlet weak var imgPlaybook: UIImageView!
    
    @IBOutlet weak var imgReminder: UIImageView!
    @IBOutlet weak var imgCertificate: UIImageView!
    
    @IBOutlet weak var lblResource: UILabel!
    @IBOutlet weak var lblPlaybook: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblCertificate: UILabel!
    var isExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isCenterBtnEnable = true
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tabAnimationforMore(_:)), name: Notification.Name("tabAnimationforMore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.centerTabDismiss(_:)), name: Notification.Name("centerTabDismiss"), object: nil)

        retractAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isExpanded = true
        expandAnimation()
    }
    
   override func viewWillDisappear(_ animated: Bool) {
    retractAnimation()
    isExpanded = false
    NotificationCenter.default.addObserver(self, selector: #selector(self.centerTabDismiss(_:)), name: Notification.Name("centerTabDismiss"), object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Action
    @IBAction func reminder(_ sender: Any) {
        print("Remainder")
        let story = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "RemindersListVC") as! RemindersListVC
        self.navigationController?.pushViewController(nextVC, animated: true)
       // self.present(nextVC, animated: true, completion: nil)
    }
    
    @IBAction func certificate(_ sender: Any) {
        print("certificate")
    }
    
    @IBAction func playBooks(_ sender: Any) {
        print("playBooks")
    }
    
    @IBAction func resources(_ sender: Any) {
        print("resources")
        let story = UIStoryboard(name: "SubMenuStoryboard", bundle: nil)
        let nextVC =  story.instantiateViewController(withIdentifier: "ResourcesVC") as! ResourcesVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK:- Local Methods
    fileprivate func retractAnimation() {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {

            self.imgReminder.transform = CGAffineTransform(translationX: 0, y: 600)
            self.imgCertificate.transform = CGAffineTransform(translationX: 0, y: 600)
            self.imgPlaybook.transform = CGAffineTransform(translationX: 0, y:600)
            self.imgResource.transform = CGAffineTransform(translationX: 0, y: 600)
            
            self.lblReminder.transform = CGAffineTransform(translationX: 0, y: 600)
            self.lblCertificate.transform = CGAffineTransform(translationX: 0, y: 600)
            self.lblPlaybook.transform = CGAffineTransform(translationX: 0, y: 600)
            self.lblResource.transform = CGAffineTransform(translationX: 0, y: 600)
        }, completion: nil)
    }
    
    fileprivate func expandAnimation() {
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, animations: {
            self.imgReminder.transform = CGAffineTransform.identity
            self.lblReminder.transform = CGAffineTransform.identity
            
            self.imgCertificate.transform = CGAffineTransform.identity
            self.lblCertificate.transform = CGAffineTransform.identity
            
            self.imgPlaybook.transform = CGAffineTransform.identity
            self.lblPlaybook.transform = CGAffineTransform.identity
            
            self.imgResource.transform = CGAffineTransform.identity
            self.lblResource.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func centerTabDismiss(_ notification: Notification) {
        if self.isViewLoaded {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
     @objc func tabAnimationforMore(_ notification: Notification) {
        if isFirsTimeLoaded {
            isFirsTimeLoaded = false
            return
        }
        guard let index = notification.userInfo as? [String:Int] else { return }
        guard let indexCount = index["index"] else {return}
        if  indexCount == 2 {
            if isExpanded {
                self.retractAnimation()
                isExpanded = false
                let indexPass:[String:Int] = ["index":0]
               NotificationCenter.default.post(name: Notification.Name("selectedTabIndex"), object: nil, userInfo: indexPass)
                
            } else {
                self.expandAnimation()
                isExpanded = true
            }
        }
    }
    
}



