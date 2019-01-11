//
//  LearningViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 22/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage
import Instabug
import FirebaseStorage
import FirebaseFirestore

var naviTitleLearning = ""

class LearningViewController: UIViewController, UIBarPositioningDelegate,UIGestureRecognizerDelegate {
    
    //MARK:- Initialization
    @IBOutlet weak var vwBottomForDrag: UIView!
    @IBOutlet weak var tableviewLearning : UITableView!
    @IBOutlet weak var viewTopview : UIView!
    
    @IBOutlet weak var dragView : UIView!
    @IBOutlet weak var dragBackGroundView : UIView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var imgDrag: UIImageView!
    @IBOutlet weak var vwTop: UIView!
    
    //DRAG
    @IBOutlet weak var btnAnonymous : UIButton!
    @IBOutlet weak var btnMe : UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblButtom: UILabel!
    
    var strUserComment = ""
    var isTabBarExpanded = false
    var refStorage = Storage.storage().reference()
    let userId = UserDefaults.standard.getUserUUID()

    //Store Locally
    var selectedIndexPath = NSIndexPath(row: 0, section: 0)
    var dragedIndexPath   = NSIndexPath(row: 0, section: 0)
    var strBuy    = ""
    var checkCourse =  UserDefaults.standard.array(forKey: "userDefCourse") ?? []
    
    //Drag and Drop View
    var show = 0
    var panGesture    = UIPanGestureRecognizer()
    var resetDragViewX :Any?
    var resetDragViewY :Any?
    
    var arrayListofCourse : [CoursedataFB] = []
    var arrayLocal        : [CoursedataFB] = []
    var arrayUserAdded : [QueryDocumentSnapshot] = []
    var selectedCourse : CoursedataFB = CoursedataFB()

    //var creatingVC : CreatingVC!
    var applyingVC : ApplyingListVC!
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // Do any additional setup after loading the view.
        naviTitleLearning = "Learning Playlists"
        self.navigationItem.title = naviTitleLearning
        //getCourseListISL()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.titleAction))
        tap.delegate = self
        
        self.dragBackGroundView.addGestureRecognizer(tap)
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setupAnimation()
        configUI()
    
        self.navigationItem.title = naviTitleLearning
       // getCourseListISL()
      //   getCourseListFirebase()
        Firestore.firestore().disableNetwork { (error) in
            self.getUserCourseList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.navigationController?.isNavigationBarHidden = false
    }
    //MARK: - UIButton Action Methods
     @objc func titleAction() {
        self.dragBackGroundView.isHidden = true
    }
    
    @IBAction func buttonAddPressed(_ sender: UIButton){
        moveNextvc()
    }
    
    @IBAction func comment(_ sender: Any) {
        
        print("Drag View Position : \(dragView.frame)")
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.instaBug()
        BugReporting.invoke()

//        DispatchQueue.main.async {
//            if self.show == 0{
//                self.dragBackGroundView.isHidden = false
//                self.show += 1
//            }
//            else{
//                self.dragBackGroundView.isHidden = true
//                self.dragView.frame.origin.y = self.resetDragViewY as! CGFloat
//                self.dragView.frame.origin.x = self.resetDragViewX as! CGFloat
//                self.show = 0
//            }
//        }
    }
    
    @IBAction func SendComment(_ sender: Any) {
        
        let index = (sender as AnyObject).selectedSegmentIndex
        switch(index){
        case 0:
            // Do something
            strUserComment = "unKnown"
        case 1:
            // Do something
            strUserComment = "me"
        default:
            break
        }
    }
    
    @IBAction func Anonymous(_ sender: Any) {
        //let vc = segue.destination as! CommentVC
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        let modellearning  = arrayListofCourse[dragedIndexPath.row]
        nextVC.courseID = modellearning.course_id!
        nextVC.userID   = "0"
        nextVC.strFromVC = "Learn"
        nextVC.strUserType = "Ananymous"
        self.present(nextVC, animated: true, completion: nil)
        //self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func addCourses(_ sender: Any) {
       let story = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "CourseListVC") as! CourseListVC
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func me(_ sender: Any) {
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        
        let modellearning  = arrayListofCourse[dragedIndexPath.row]
        nextVC.courseID = modellearning.course_id!
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Learn"
        nextVC.strUserType = "Me"
        self.present(nextVC, animated: true, completion: nil)
       // self.navigationController?.pushViewController(nextVC, animated: true)
    }
}



