//
//  CourseListVC.swift
//  GICM
//
//  Created by Rafi on 20/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage
import FirebaseFirestore

class CourseListVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate{

    //MARK:- Initialization
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblCourse: UITableView!
    
    @IBOutlet weak var collDashboard: UICollectionView!
    
    
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker  = ""
    var course_id = ""
    let allPosting = ["Job Seeker", "Analyst","Consultant","Senior Consultant","Managing Consultant","Principal","Vice President","Business Analyst","Associate","Engagement Manager","Associate Partner","Partner","Associate Consultant","Senior Associate Consultant","Case Team Leader","Manager","Junior","Senior","Senior Manager","Director","Supervisor"]
    
    var arrRole = UserDefaults.standard.array(forKey: "CurrentPosting") ?? [""]
    
    
    
    var arrContributionSections = ["New Idea","Develop concept","Feedback","Own business"]
    var arrarContributionModuleImage = [#imageLiteral(resourceName: "NewIdea"),#imageLiteral(resourceName: "DevelopmentConcept"),#imageLiteral(resourceName: "Feedback"),#imageLiteral(resourceName: "OwnBussiness")]
    
   // var arrSearch:[String] = []
    
    var arrImage = ["Art&Design","Business&Management","Computer&Technology", "Education&Teaching","Nurcing&Health Care","Business&Management","Computer&Technology",]
    
    var refStorage = Storage.storage().reference()
    var arrayListofCourse : [CoursedataFB] = []
    var arrSearch        : [CoursedataFB] = []
    let userId = UserDefaults.standard.getUserUUID()

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.arrRole = UserDefaults.standard.array(forKey: "CurrentPosting") ?? self.allPosting
        getCourseListFirebase()
        createCustomPickerInstance()
        Utilities.leftGapView(self.txtSearch)
        txtSearch.addTarget(self, action: #selector(searchRecordsAsPerText(_ :)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- API Integation
    func getCourseListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("courseList")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseIntoCourse(snap:snap)
                self.tblCourse.reloadData()
            }
        }
    }
    
    func parseIntoCourse(snap:[QueryDocumentSnapshot]){
        self.arrayListofCourse.removeAll()
        for obj in snap{
            let model = CoursedataFB()
            model.course_description = obj["course_description"] as? String ?? ""
            model.course_short_desc = obj["course_short_desc"] as? String ?? ""
            model.course_title = obj["course_title"] as? String ?? ""
            model.thumbnail = obj["thumbnail"] as? String ?? ""
            model.comments = obj["comments"] as? String ?? ""
            model.course_id = obj.documentID
            var arrSub : [CourseListDataFB] = []
            for sub in obj["course_list"] as? [[String:String]] ?? []{
                let submodel = CourseListDataFB()
                submodel.course_name = sub["course_name"] ?? ""
                submodel.courselist_id = sub["courselist_id"] ?? ""
                submodel.sub_content = sub["sub_content"] ?? ""
                arrSub.append(submodel)
            }
            model.course_list = arrSub
            self.arrayListofCourse.append(model)
        }
        
        self.arrSearch = self.arrayListofCourse
        
        let role = UserDefaults.standard.string(forKey: "Role") ?? ""
        print("Role \(role)")
        
        if (role.count) > 0 {
            self.roleBasedCourseList(strPosting: role)
        }else{
            self.arrSearch = self.arrayListofCourse
            self.tblCourse.reloadData()
        }

    }
    
    
    //Search
    func roleBasedCourseList(strPosting: String){
        self.arrSearch = self.arrayListofCourse.filter({$0.course_short_desc?.range(of: strPosting, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
        self.tblCourse.reloadData()
    }
    
    //MARK:- Local Methods
    @objc func searchRecordsAsPerText(_ textfield:UITextField) {
        
        if (textfield.text?.count)! > 0 {
        self.arrSearch = self.arrayListofCourse.filter({$0.course_title?.range(of: textfield.text!, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
        self.tblCourse.reloadData()
        }else{
           self.arrSearch = self.arrayListofCourse
            self.tblCourse.reloadData()
        }
//        arrSearch.removeAll()
//        if textfield.text?.count != 0 {
//            for strModelText in arrRole {
//                let mobileRange = (strModelText).lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil,   locale: nil)
//
//                if  mobileRange != nil
//                {
//                    arrSearch.append(strModelText)
//                }
//            }
//        } else {
//            arrSearch = arrRole
//        }
      //  tblCourse.reloadData()
    }
    
    //MARK:- Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearch{
            listOfCompany(listData: arrRole as! [String])
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSearch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseListCell", for: indexPath) as! CourseListCell
        cell.lblCourse.text = self.arrSearch[indexPath.row].course_title
      //  cell.imgCourse.image = UIImage(named: arrImage[indexPath.row])//arrImage[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
        course_id = arrSearch[indexPath.row].course_id ?? ""
        self.showBuyAlert()
    }
    func showBuyAlert() {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to Add?", comment:""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.addCourse()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    func addCourse(){
        //check already added
        let refEx = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo: userId).whereField("course_id", isEqualTo: course_id)
        refEx.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                Utilities.sharedInstance.showToast(message: "Already added")
            }
            else
            {
                // if new add
                let ref = FirebaseManager.shared.firebaseDP!.collection("course_user")
                ref.addDocument(data: self.getCourseJson()) { (error) in
                    if error == nil{
                        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.course_add)!)
                    }
                }
            }
        }
    }
    func getCourseJson() -> [String:Any]{
        return ["user_id" : userId,
                "course_id" : course_id,
                "buy" : "0"
        ]
    }
    
    //MARK:- Collection View delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.collDashboard?.collectionViewLayout.invalidateLayout()
            self.collDashboard.layoutIfNeeded()
            self.collDashboard.reloadData()
        }
    }
    
    //MARK:- Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrContributionSections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let dashBoardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LearningSecCell", for: indexPath) as! LearningSecCell
        dashBoardCell.layer.borderWidth = 1.0
        dashBoardCell.layer.borderColor = UIColor.init(red: 214/255.0, green: 214/255.0, blue: 214/255.0, alpha: 1.0).cgColor
        dashBoardCell.lblModuleName.text = arrContributionSections[indexPath.row]
        dashBoardCell.imgModule.image = arrarContributionModuleImage[indexPath.row] as UIImage
        return dashBoardCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let dimension:CGFloat = self.view.frame.size.width / 2
        return CGSize(width: dimension, height: collectionView.frame.size.height/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let story = UIStoryboard(name: "CallBackupStoryboard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
        nextVC.fromVC = "Contribution"
        nextVC.strTitle = arrContributionSections[indexPath.row]
        nextVC.strContributionType = arrContributionSections[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        //        if indexPath.row == 0{
        //            print("By Role Suggestion")
        //            let story = UIStoryboard(name: "Main", bundle: nil)
        //            let nextVC = story.instantiateViewController(withIdentifier: "RoleVC") as! RoleVC
        //            self.navigationController?.pushViewController(nextVC, animated: true)
        //
        //        }else if indexPath.row == 1{
        //            print("Course list")
        //            let story = UIStoryboard(name: "Main", bundle: nil)
        //            let nextVC = story.instantiateViewController(withIdentifier: "CourseListVC") as! CourseListVC
        //            self.navigationController?.pushViewController(nextVC, animated: true)
        //
        //        }else if indexPath.row == 2{
        //            print("Contributions")
        //            let story = UIStoryboard(name: "Main", bundle: nil)
        //            let nextVC = story.instantiateViewController(withIdentifier: "ContributionVC") as! ContributionVC
        //            self.navigationController?.pushViewController(nextVC, animated: true)
        //        }
    }
}



//MARK:- CustomPicker Methods
extension CourseListVC :CustomPickerDelegate {
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func listOfCompany(listData : [String]){
        
        customPickerObj.totalComponents = 1
        customPickerObj.arrayComponent = listData
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_String)
        customPickerObj.customPicker.reloadAllComponents()
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
        let pickerDateValue = item as! String
        // strCompanyName = pickerDateValue
        self.txtSearch.text = pickerDateValue
        self.roleBasedCourseList(strPosting: pickerDateValue)
        //  getCompanyPostingList(companyName: strCompanyName)
    }
    
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}


