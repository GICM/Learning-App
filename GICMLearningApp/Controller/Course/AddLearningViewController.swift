//
//  AddLearningViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 28/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class AddLearningViewController: UIViewController {
  
  @IBOutlet weak var txtCourseTitle: UITextField!
  
  //MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    Utilities.sharedInstance.setImageAtLeft(image:"CoruseTitle",textField: txtCourseTitle)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: - UIButton Action Methods
  @IBAction func buttonBackPressed(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
}
