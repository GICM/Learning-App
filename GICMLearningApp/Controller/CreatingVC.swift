//
//  CreatingVC.swift
//  GICMLearningApp
//
//  Created by CIPL0449MOBILITY on 11/07/18.
//  Copyright © 2018 Praveenkumar R. All rights reserved.
//

import UIKit


class SubMenuVC: UIViewController {
    
    @IBOutlet weak var imgResource: UIImageView!
    @IBOutlet weak var imgPlaybook: UIImageView!
    
    @IBOutlet weak var imgReminder: UIImageView!
    @IBOutlet weak var imgCertificate: UIImageView!
    
    @IBOutlet weak var lblResource: UILabel!
    @IBOutlet weak var lblPlaybook: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var lblCertificate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imgReminder.transform = CGAffineTransform(translationX: 0, y: 500)
        imgCertificate.transform = CGAffineTransform(translationX: 0, y: 500)
        imgPlaybook.transform = CGAffineTransform(translationX: 0, y: 500)
        imgResource.transform = CGAffineTransform(translationX: 0, y: 500)
        
        lblReminder.transform = CGAffineTransform(translationX: 0, y: 500)
        lblCertificate.transform = CGAffineTransform(translationX: 0, y: 500)
        lblPlaybook.transform = CGAffineTransform(translationX: 0, y: 500)
        lblResource.transform = CGAffineTransform(translationX: 0, y: 500)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.imgReminder.transform = CGAffineTransform.identity
            self.lblReminder.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
            self.imgCertificate.transform = CGAffineTransform.identity
            self.lblCertificate.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseInOut, animations: {
            self.imgPlaybook.transform = CGAffineTransform.identity
            self.lblPlaybook.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseInOut, animations: {
            self.imgResource.transform = CGAffineTransform.identity
            self.lblResource.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



