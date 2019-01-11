//
//  EditProfileViewController.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage
import Instabug

class EditProfileViewController: UIViewController {
  
  @IBOutlet weak var txtUserName: UITextField!
  @IBOutlet weak var txtEmail: UITextField!
  @IBOutlet weak var txtDOB: UITextField!
  @IBOutlet weak var imgProfilePhoto: UIImageView!
  
  //Custom Picker Instance variable
  var customPickerObj : CustomPicker!
  var selectedPicker      = ""
  
  let ImagePicker = UIImagePickerController()
  
  var strBase64 = ""
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    //getProfileDetailsAPI()
    
    getUserData()
    setImageAtLeft()
    NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
    Utility.sharedInstance.isShowMenu = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.isShowMenu = true
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: - UIButton Action Methods
  @IBAction func buttonBackPressed(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
  @IBAction func buttonSavePressed(_ sender: UIButton){
    let bISSuccess = addCreateValidate()
    if bISSuccess {
     // requestEditAPI()
      requestEditFirebase()
    }
  }
  
  @IBAction func buttonUploadProfileTapped(_ sender: UIButton){
    chooseuploadImage()
  }
  
  //MARK: - GetEdit
  func requesrGet() -> [String:Any]{
    return ["user_id" : UserDefaults.standard.getUserID()]
  }
  func getUserData()
  {
    _ = FirebaseManager.shared.firebaseDP!.collection("users").whereField("e_mail", isEqualTo: UserDefaults.standard.getEmail()).addSnapshotListener({ (snapshot, error) in
        if let snap = snapshot?.documents {
            if snap.count > 0
            {
                self.txtUserName.text = snap[0].get("user_name") as? String ?? ""
                self.txtEmail.text    = snap[0].get("e_mail") as? String ?? ""
                self.txtDOB.text      = snap[0].get("dob")as? String ?? ""
                if let profileStr = snap[0].get("prof_pic") as? String, profileStr.count > 0{
                    let dataDecoded : Data = Data(base64Encoded: profileStr)!
                    self.imgProfilePhoto.image = UIImage(data: dataDecoded)
                }
            }
            else
            {
                print("Get user details Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
        else
        {
            print("Unable get user details: \(String(describing: error?.localizedDescription))")
        }
    })
    }
}

extension EditProfileViewController: RSKImageCropViewControllerDelegate{
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.imgProfilePhoto .image = croppedImage
        
        // self.imgProfilePhoto.image = image
        imgProfilePhoto.layer.cornerRadius = 70
        imgProfilePhoto.clipsToBounds      = true
        
        let imageData: Data! = UIImageJPEGRepresentation(imgProfilePhoto.image!, 0.2)
        strBase64 = imageData.base64EncodedString()
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension EditProfileViewController:  RSKImageCropViewControllerDataSource {
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        return UIBezierPath(rect: controller.maskRect)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect{
        return CGRect(x: 0, y: 0, width: 375, height: 200)
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}
