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
class TabBarViewController: UITabBarController, SMFeedbackDelegate{
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
        
        
        self.tabBar.items?[0].image = UIImage(named: "Learning")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items?[0].selectedImage = UIImage(named: "Learning_Selected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.tabBar.items?[1].image = UIImage(named: "Applying")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items?[1].selectedImage = UIImage(named: "Applying_Selected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.tabBar.items?[3].image = UIImage(named: "callBackUp")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items?[3].selectedImage = UIImage(named: "callBackUp_Selected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.profileImageChange()
        
    }
    
    func profileImageChange(){
        let isProfileChange = UserDefaults.standard.bool(forKey: "ProfileIconChanged")
        if isProfileChange{
            let isFullyComplated = UserDefaults.standard.bool(forKey: "ProfileImageFullyChanges")
            if isFullyComplated{
                let imageProfile = UserDefaults.standard.string(forKey: "profileIcon") ?? ""
                if let dataDecoded : Data = Data(base64Encoded: imageProfile){
                    if let profileImage = UIImage(data: dataDecoded)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                    {
                        self.tabBar.items?[4].image = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                        self.tabBar.items?[4].selectedImage = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                    }
                }
            }else{
                let imageName = UserDefaults.standard.string(forKey: "profileIcon") ?? "Profile"
                let imag = UIImage(named: "\(imageName)")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                
                self.tabBar.items?[4].image = imag//Utilities.sharedInstance.resizeImage(image: imag!, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[4].selectedImage = imag//Utilities.sharedInstance.resizeImage(image: imag!, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                
            }
        }else{
            self.tabBar.items?[4].image = UIImage(named: "Profile")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            self.tabBar.items?[4].selectedImage = UIImage(named: "profile_Selected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        CustomMenu.sharedInstance.hideMenu()
        
    }
    
    @objc func tabbarImageChange(){
        let isProfileChange = UserDefaults.standard.bool(forKey: "ProfileIconChanged")
        if isProfileChange{
            let isFullyComplated = UserDefaults.standard.bool(forKey: "ProfileImageFullyChanges")
            if isFullyComplated{
            let imageProfile = UserDefaults.standard.string(forKey: "profileIcon") ?? ""
            if let dataDecoded : Data = Data(base64Encoded: imageProfile){
                if let profileImage = UIImage(data: dataDecoded)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                {
                    self.tabBar.items?[4].image = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                    self.tabBar.items?[4].selectedImage = Utilities.sharedInstance.resizeImage(image: profileImage, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                }
                }
            }else{
                let imageName = UserDefaults.standard.string(forKey: "profileIcon") ?? "Profile"
                let imag = UIImage(named: "\(imageName)")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                
                self.tabBar.items?[4].image = imag//Utilities.sharedInstance.resizeImage(image: imag!, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[4].selectedImage = imag//Utilities.sharedInstance.resizeImage(image: imag!, targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysOriginal)
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
    

    
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}


