//
//  CreatingTabVC.swift
//  GICMLearningApp
//
//  Created by CIPL on 21/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CreatingTabVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblTitle.text = "Creating"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
