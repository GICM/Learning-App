//
//  AddProjectVC.swift
//  GICM
//
//  Created by Rafi on 27/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage

class AddProjectVC: UIViewController {

    //MARK:- Initialization
    @IBOutlet weak var txtProjectName: UITextField!
    @IBOutlet weak var txtClientName: UITextField!
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDAte: UITextField!
    @IBOutlet weak var imgProject: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    
    //Param for add
    var projectName = ""
    var clientName  = ""
    var startDate   = ""
    var endDate     = ""
    let ImagePicker = UIImagePickerController()
    var strBase64 = ""
    
    var fromVC = ""
    var projectModelObj = ProjectModelFB()
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        configUI()
    }
    
   
    
    //MARK:- Local Methods
    func configUI(){
        createCustomPickerInstance()
        Utilities.leftGapView(txtProjectName)
        Utilities.leftGapView(txtClientName)
        Utilities.leftGapView(txtStartDate)
        Utilities.leftGapView(txtEndDAte)
        
        if fromVC == "edit"{
            txtProjectName.text = projectModelObj.project_name
            txtClientName.text = projectModelObj.client_name
            txtStartDate.text = projectModelObj.start_date
            txtEndDAte.text = projectModelObj.end_date
//            imgProject.sd_setImage(with: URL(string: projectModelObj.project_image!), placeholderImage: UIImage(named: "noImage"))
            if let profileStr = projectModelObj.project_image, profileStr.count > 0{
                let dataDecoded : Data = Data(base64Encoded: profileStr)!
                imgProject.image = UIImage(data: dataDecoded)
            }
           
            btnAdd.setTitle("Update", for: .normal)
        }
    }
    
    //MARK:- Button Action
    @IBAction func addProject(_ sender: Any) {
        
        if fromVC == "edit"{
            let bISSuccess = Validate()
            if bISSuccess {
            //    editProjectAPI()
                editProjectAPIFirebase()
                self.backAction("")
            }
        }
            //Add Project API
        else{
            let bISSuccess = Validate()
            if bISSuccess {
              //  addProjectAPI()
                addProjectAPIFirebase()
                self.backAction("")
            }
        }
    }
    
    @IBAction func projectImage(_ sender: Any) {
        chooseuploadImage()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- API
    func getAddProjectJSON() -> [String:Any]{
        return ["project_name" : projectName,
                "client_name"  : clientName,
                "start_date" : startDate,
                "end_date" :endDate ,
                "project_image" : strBase64,
                "user_id" : UserDefaults.standard.getUserUUID(),
                "project_id" : "0"]
    }
    
    //MARK: - Add Project
    func addProjectAPIFirebase(){
        _ = FirebaseManager.shared.firebaseDP!.collection("projects").addDocument(data: self.getAddProjectJSON(), completion: { (err) in
            if err  != nil{
                print("add Project Error: \(String(describing: err?.localizedDescription))")
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Project creation has failed, try agian later", controller: self)
            }
            else
            {
                self.updateProjectID()
                Utilities.showSuccessFailureAlertWithDismissHandler(title: "success!", message: "Project has created successfully", controller: self, alertDismissed: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    func updateProjectID(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID()).whereField("project_id", isEqualTo: "0")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let refExist = FirebaseManager.shared.firebaseDP!.collection("projects").document(snap[0].documentID)
                refExist.updateData(["project_id" :"\(snap[0].documentID)"])
            }
        }
    }
    func editProjectAPIFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(projectModelObj.project_id!)
        ref.updateData(self.editProjectJSON(), completion: { (error) in
            print("Edit project Detail Error: \(String(describing: error))")
            if error == nil{
                Utilities.showSuccessFailureAlertWithDismissHandler(title: "success!", message: "Updated Successfully", controller: self, alertDismissed: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
    
    //MARK:- Edit Project
    func editProjectJSON() -> [String:Any]{
        if strBase64 == ""{
            strBase64 = projectModelObj.project_image!
        }
        return ["project_name" : txtProjectName.text!,
                "client_name"  : txtClientName.text!,
                "start_date" : txtStartDate.text!,
                "end_date" :   txtEndDAte.text! ,
                "project_image" : strBase64,
                "project_id" : projectModelObj.project_id!]
    }

    // MARK: - Validation Methods
    func Validate() -> Bool {
        var bIsSuccess     = false
        var errorMessage   = ""
        projectName = (txtProjectName.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        clientName = (txtClientName.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        startDate = (txtStartDate.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        endDate = (txtEndDAte.text?.trimmingCharacters(in:.whitespacesAndNewlines))!
        
        if projectName == ""{
            errorMessage = Constants.ErrorMessage.project
        }
        else if clientName == ""{
            errorMessage = Constants.ErrorMessage.clientName
            
        }else if startDate == ""{
            errorMessage = Constants.ErrorMessage.startdate
        }
        else if endDate == ""{
            errorMessage = Constants.ErrorMessage.enddate
        }
        else{
            bIsSuccess = true
        }
        if !bIsSuccess {
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: errorMessage, controller: self)
        }
        return bIsSuccess
    }
}

//MARK: - UITextFieldDelegate Methods
extension AddProjectVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && string == " ") {
            return false;
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtStartDate {
            selectedPicker = "start"
            dismissKeyboard()
            self.dateOfBirthAction(setMinDate: false)
            return false
        }
        else if textField == txtEndDAte {
            if (txtStartDate.text?.isEmpty)!{
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: Constants.ErrorMessage.startdate, controller: self)
                dismissKeyboard()
                return false
            }else{
                selectedPicker = "end"
                dismissKeyboard()
                self.dateOfBirthAction(setMinDate: true)
                return false
            }
        }
        return true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK:- CustomPicker Methods
extension AddProjectVC :CustomPickerDelegate {
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func dateOfBirthAction(setMinDate: Bool)
    {
        self.dismissKeyboard()
        addCustomPicker()
        //self.customPickerObj.customPickerOrientation()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_Date)
        customPickerObj.customDatePicker.datePickerMode = .date
        if (!setMinDate){
            self.customPickerObj.customDatePicker.date = Date()
          //self.customPickerObj.customDatePicker.minimumDate = Calendar .current .date(byAdding: Calendar.Component.year, value: 0, to: Date())
        }
        else
        {
            let formater = DateFormatter()
            formater.dateFormat = "dd/MM/yyyy"
            var minimumDate = ""
            minimumDate = startDate
            
           self.customPickerObj.customDatePicker.minimumDate = formater.date(from: minimumDate)//?.addingTimeInterval(60*60*24)
        }
    }
    
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
        self.customPickerObj.vwBaseView.frame.size.height = self.view.frame.size.height
        self.customPickerObj.vwBaseView.frame.size.width = self.view.frame.size.width
    }
    
    func removeCustomPicker(){
        if customPickerObj != nil{
            customPickerObj.view.removeFromSuperview()
        }
    }
    
    func itemPicked(item: AnyObject) {
        removeCustomPicker()
        let pickerDateValue = item as! Date
        let dateFormatObj = DateFormatter()
        dateFormatObj.dateFormat = "dd/MM/yyyy"
        dateFormatObj.locale = Locale(identifier: "en-US")
        
        if selectedPicker == "start"{
            let strDate =  dateFormatObj.string(from: pickerDateValue)
            txtStartDate.text = strDate
            startDate = strDate
            txtEndDAte.text = ""
        }
        else if selectedPicker == "end"{
            let strDate =  dateFormatObj.string(from: pickerDateValue)
            txtEndDAte.text = strDate
        }
        selectedPicker = ""
    }
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}

//MARK: - UIImagePickerControllerDelegate Methods
extension AddProjectVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func chooseuploadImage(){
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        ImagePicker.delegate = self
    }
    
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        //You will get cropped image here..
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            DispatchQueue.main.async {
                self.strBase64 = ""
                self.imgProject.image = image
                
                let imageData: Data! = UIImageJPEGRepresentation(self.imgProject.image!, 0.2)
                self.strBase64 = imageData.base64EncodedString()
            }
        }else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - OpenCamera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            
            ImagePicker.sourceType = UIImagePickerControllerSourceType.camera
            ImagePicker.allowsEditing = true
            self.present(ImagePicker, animated: true, completion: nil)
            
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - OpenGallary
    func openGallary(){
        ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        ImagePicker.allowsEditing = true
        self.present(ImagePicker, animated: true, completion: nil)
    }
}

