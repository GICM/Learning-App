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
    @IBOutlet weak var tblCourse: UITableView!
    
    @IBOutlet weak var collDashboard: UICollectionView!
    
    var course_id = ""
    
    var arrContributionSections = ["New Idea","Develop concept","Feedback","Own business"]
    var arrarContributionModuleImage = [#imageLiteral(resourceName: "NewIdea"),#imageLiteral(resourceName: "DevelopmentConcept"),#imageLiteral(resourceName: "Feedback"),#imageLiteral(resourceName: "OwnBussiness")]
    
   // var arrSearch:[String] = []
    
    
    var refStorage = Storage.storage().reference()
    var arrayListofCourse : [CoursedataFB] = []
    var arrSearch        : [CoursedataFB] = []
    let userId = UserDefaults.standard.getUserUUID()

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("***********************************************")
        NSLog(" CourseListVC View did load  ")
        getCourseListFirebase()

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
        self.tblCourse.reloadData()
        
    }
    
    
    //Search
    func roleBasedCourseList(strPosting: String){
        self.arrSearch = self.arrayListofCourse.filter({$0.course_short_desc?.range(of: strPosting, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
        self.tblCourse.reloadData()
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
        course_id = arrSearch[indexPath.row].course_id ?? ""
        self.addCourse()
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
                        self.navigationController?.popViewController(animated: true)
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
        let email = UserDefaults.standard.getEmail()
        if email.isEmpty{
            Utilities.sharedInstance.showToast(message: "Please add email in profile")
        }else{
       // Utilities.sharedInstance.showToast(message: "Development in progress")
        let story = UIStoryboard(name: "CallBackupStoryboard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "SendCallBackVC") as! SendCallBackVC
        nextVC.fromVC = "Contribution"
        nextVC.strTitle = arrContributionSections[indexPath.row]
        nextVC.strContributionType = arrContributionSections[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}



