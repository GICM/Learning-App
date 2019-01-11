//
//  CreateViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {
  
  @IBOutlet weak var txtUserName: UITextField!
  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtPassword: UITextField!
  @IBOutlet weak var txtCnfPassword: UITextField!
  @IBOutlet weak var txtDOB: UITextField!
  
  @IBOutlet weak var imgProfilePhoto: UIImageView!
  
  //Custom Picker Instance variable
  var customPickerObj : CustomPicker!
  var selectedPicker      = ""
  var isCustomPickerChossed: Bool = false
  
  let ImagePicker = UIImagePickerController()
  var strBase64 = ""
  
  //MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setImageAtLeft()
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  //MARK: - UIButton Action Methods
  @IBAction func buttonBackPressed(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  @IBAction func buttonCreatePressed(_ sender: UIButton){
    
    let bISSuccess = addCreateValidate()
    if bISSuccess {
      //requestRegisterAPI()
        requestRegisterFirebase()
    }
  }
  @IBAction func buttonUploadProfileTapped(_ sender: UIButton){
    chooseuploadImage()
  }
}


