//
//  InterviewPreparationViewController.swift
//  GICMLearningApp
//
//  Created by Rafi on 25/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug


class InterviewPreparationViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableviewSegmentedControl: UITableView!
    @IBOutlet weak var tableviewInterviewPreparation: UITableView!
    @IBOutlet weak var viewSegmentedControl: UIView!
    @IBOutlet weak var imageviewDropDown: UIImageView!
    
    @IBOutlet weak var viewPopUp: UIView!
    @IBOutlet weak var btnTitleTopBar: UIButton!
    var arraySegmentedControl  = ["1","2"]
    public var modelcourselist : [CourseListDataFB] = []
    public var navigationTitle = ""
    var courseID = ""
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       // btnTitleTopBar.setTitle(navigationTitle, for: .normal)
       lblTitle.text = navigationTitle
      //  btnTitleTopBar.addTarget(self, action: #selector(titleAction), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(titleAction))
        tap.delegate = self
        
        self.viewPopUp.addGestureRecognizer(tap)
        
        viewPopUp.isHidden = true
        self.navigationItem.title = navigationTitle
     
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        self.tableviewInterviewPreparation.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        segmentedControl.tintColor    = UIColor.white
        viewSegmentedControl.isHidden = true
        visualEffectView.isHidden     = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        self.visualEffectView.addGestureRecognizer(gestureRecognizer)
        
        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.isShowMenu = true
    }
    
    override func viewDidLayoutSubviews() {
        btnTitleTopBar.titleLabel?.center.x = self.view.center.x
        btnTitleTopBar.imageView?.center.x = self.view.center.x
        btnTitleTopBar.titleLabel?.center.y = -10
        btnTitleTopBar.imageView?.center.y = 20
        //    btnTitleTopBar.imageEdgeInsets = UIEdgeInsetsMake(20, (btnTitleTopBar.frame.width*0.5) - ((btnTitleTopBar.imageView?.frame.width)!*0.5), 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func buttonBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableviewSegmentedControl.isHidden = false
        case 1:
            tableviewSegmentedControl.isHidden = true
        case 2:
            tableviewSegmentedControl.isHidden = false
        default:
            break;
        }
    }
//    @IBAction func buttonViewDialogopenPressed(_ sender: UIButton){
//        UIView.animate(withDuration: 0.4, animations: {
//            self.imageviewDropDown.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
//            self.visualEffectView.isHidden     = false
//            self.viewSegmentedControl.isHidden = false
//        })
//    }
  
    @IBAction func buttonViewDialogopenPressed(_ sender: UIButton){
        self.titleAction()
    }
    
    @objc func titleAction() {
        if viewPopUp.isHidden {
            self.viewPopUp.transform  = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            UIView.animate(withDuration: 0.5) {
                self.viewPopUp.isHidden = false
                self.btnTitleTopBar.setImage(#imageLiteral(resourceName: "Up"), for: .normal)
                self.viewPopUp.transform  = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
        } else {
            self.viewPopUp.transform  = CGAffineTransform(scaleX: 1.0, y: 1.0)
            UIView.animate(withDuration: 0.5, animations: {
                self.btnTitleTopBar.setImage(#imageLiteral(resourceName: "Down"), for: .normal)
                self.viewPopUp.transform  = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            }) { (completed) in
                self.viewPopUp.isHidden = true
            }
        }
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.4, animations: {
            self.imageviewDropDown.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            self.viewSegmentedControl.isHidden = true
            self.visualEffectView.isHidden     = true
        })
    }
    
    //MARK:- Comment
//    @IBAction func comment(_ sender: Any) {
//        let alertController = UIAlertController(title: "Profile", message: "Enter a Comment", preferredStyle: .alert)
//
//        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
//            guard let textFields = alertController.textFields,
//                textFields.count > 0 else {
//                    // Could not find textfield
//                    return
//            }
//
//            let field = textFields[0]
//            // store your data
//            print(field)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//
//        alertController.addTextField { (textField) in
//            textField.placeholder = "Comment"
//        }
//
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//
//        self.present(alertController, animated: true, completion: nil)
//    }
}
//MARK: - UITableViewDelegate & UITableViewDataSource Methods
extension InterviewPreparationViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableviewSegmentedControl {
            return arraySegmentedControl.count
        }else{
            return modelcourselist.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        if tableView == tableviewSegmentedControl{
            cell = tableView.dequeueReusableCell(withIdentifier:"SegmentedControlcell", for: indexPath)
            cell.selectionStyle = .none
            
            let label = cell.viewWithTag(100) as! UILabel
            label.text = arraySegmentedControl[indexPath.row]
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier:"InterviewPreparationcell", for: indexPath)
            cell.selectionStyle = .none
            
            let modelCourseList = modelcourselist[indexPath.row]
            let label = cell.viewWithTag(101) as! UILabel
            label.text = modelCourseList.course_name ?? ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableviewInterviewPreparation{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowContent") as! ShowContentViewController
            
            let modelCourseList = modelcourselist[indexPath.row]
            vc.subContent = modelCourseList.sub_content ?? ""
            vc.navigationItem.title = modelCourseList.course_name ?? ""
            vc.strFileName = modelCourseList.course_name ?? ""
            vc.docIndex = indexPath.row %  8
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
