//
//  CreatingVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 11/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import UserNotificationsUI



class LocationVC: UIViewController {
 
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // status is not determined
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func selectThisLocation(_ sender: Any) {
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



    



