//
//  TabBarViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 23/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage

var isCenterBtnEnable = false
class TabBarViewController: UITabBarController, SMFeedbackDelegate,UITabBarControllerDelegate{
    let app = UIApplication.shared.delegate as? AppDelegate
    var feedbackVC : SMFeedbackViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.items![2].isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.feedbackHanlder), name: Notification.Name("NofifyFeedback"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tabbarImageChange), name: Notification.Name("changeTabBarImage"), object: nil)
        
        self.configUI()
    }
    
    func configUI()
    {
        // Do any additional setup after loading the view.
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if UserDefaults.standard.isLoggedIn(){
            if let dataDecoded : Data = Data(base64Encoded: UserDefaults.standard.getProfileImage()){
                if let profileImage = UIImage(data: dataDecoded)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                {
                    self.tabBar.items?[4].image = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                    self.tabBar.items?[4].selectedImage = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                }
            }
        }
        
        self.tabBar.items?[0].image = UIImage(named: "Learning")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items?[0].selectedImage = UIImage(named: "Learning")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.tabBar.items?[1].image = UIImage(named: "Applying")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items?[1].selectedImage = UIImage(named: "Applying")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        CustomMenu.sharedInstance.hideMenu()
        
    }
    
    @objc func tabbarImageChange(){
        if UserDefaults.standard.isLoggedIn(){
            if let dataDecoded : Data = Data(base64Encoded: UserDefaults.standard.getProfileImage()){
                if let profileImage = UIImage(data: dataDecoded)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                {
                    self.tabBar.items?[4].image = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                    self.tabBar.items?[4].selectedImage = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
    
    @objc func feedbackHanlder(){
        let alert = UIAlertController(title: "Choose Survey", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "NPS iOS", style: .default, handler: { _ in
            self.feedbackVC = SMFeedbackViewController.init(survey: "99Q55W6")
            self.feedbackVC?.delegate = self
            self.feedbackVC?.present(from: self, animated: true, completion: {
            })
        }))
        alert.addAction(UIAlertAction(title: "Weekly poll iOS", style: .default, handler: { _ in
            self.feedbackVC = SMFeedbackViewController.init(survey: "TWBQV6V")
            self.feedbackVC?.delegate = self
            self.feedbackVC?.present(from: self, animated: true, completion: {
            })
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func respondentDidEndSurvey(_ respondent: SMRespondent!, error: Error!) {
        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.thanks_survey)!)
    }
}






