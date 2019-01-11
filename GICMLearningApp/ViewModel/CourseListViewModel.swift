//
//  LearningViewModel.swift
//  GICMLearningApp
//
//  Created by Rafi on 29/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension LearningViewController {
    
    //MARK:- Move to add
    func moveNextvc(){
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.addLearning) as! AddLearningViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Get CourseListISL
    func getCourseListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("courseList")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseIntoModel(snap:snap)
                self.tableviewLearning.reloadData()
            }
        }
    }
    func getUserCourseList(){
        _ = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo: self.userId).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.arrayUserAdded.removeAll()
                self.arrayUserAdded += snap
                self.getCourseListFirebase()
            }else{
                Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.addCourse)!)
            }
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        self.arrayListofCourse.removeAll()
        
        var allCourse : [CoursedataFB] = []
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
            allCourse.append(model)
        }
        
        for courseObj in arrayUserAdded {
            if let obj = allCourse.filter({$0.course_id == courseObj.get("course_id") as? String}).first{
                if courseObj.get("buy") as? String == "1"{
                    obj.buy = "1"
                }else{
                    obj.buy = "0"
                }
                self.arrayListofCourse.append(obj)
            }
        }
//        self.arrayLocal = self.arrayListofCourse.filter({$0.course_short_desc?.range(of: "job-seeker", options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
//        print(self.arrayLocal.count)
//        print(self.arrayLocal[0].course_title)
    }
    
    //MARK:- Show Alert
    func showBuyAlert() {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to Buy?", comment:""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.buyCourse()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    //MARK:- Local Methods
    func configUI(){
        //self.navigationController?.isNavigationBarHidden = false
        dragHide()
        //        btnAnonymous.layer.cornerRadius = btnAnonymous.frame.size.height/2
        //        btnMe.layer.cornerRadius = btnMe.frame.size.height/2
        lblComment.text = ""
        self.dragBackGroundView.frame = self.view.frame
        self.dragBackGroundView.isHidden = true
        self.view.addSubview(dragBackGroundView)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(LearningViewController.draggedView(_:)))
        dragView.isUserInteractionEnabled = true
        dragView.addGestureRecognizer(panGesture)
        resetDragViewX = dragView.frame.origin.x
        resetDragViewY = dragView.frame.origin.y
    }
    
    //BUY Product
    func buyCourse(){
        let refEx = FirebaseManager.shared.firebaseDP!.collection("course_user").whereField("user_id", isEqualTo: userId).whereField("course_id", isEqualTo: selectedCourse.course_id!)
        refEx.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                let ref = FirebaseManager.shared.firebaseDP!.collection("course_user").document(snap[0].documentID)
                ref.updateData(["buy" :"1"], completion: { (error) in
                    if error == nil{
                        Utilities.sharedInstance.showToast(message: (FirebaseManager.shared.toastMsgs.buy_course)!)
                        self.nextVC()
                    }
                })
            }
        }
    }
    
    //Drag and Drop
    @objc func draggedView(_ sender:AnyObject){
        self.view.bringSubview(toFront: dragView)
        let translation = sender.translation(in: self.view)
        dragView.center = CGPoint(x: dragView.center.x + translation.x, y: dragView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let dragCenter = CGPoint(x: translation.x+70, y: translation.y+70)
        let buttonPosition:CGPoint = dragView.convert(dragCenter, to: self.tableviewLearning)
        if let indexPath = self.tableviewLearning.indexPathForRow(at: buttonPosition) {
            dragedIndexPath = indexPath as NSIndexPath
                let commentObj = arrayListofCourse[indexPath.row]
                imgDrag.image = UIImage.init(named:"Drag")
                lblTitle.text = commentObj.course_title ?? ""
                lblComment.text = commentObj.comments ?? ""
                dragShow()
                print("Index: \(String(describing: indexPath))")
            
        } else {
            imgDrag.image = UIImage.init(named:"emptyDrag")
            dragHide()
        }
    }
    
    func dragHide(){
        lblComment.isHidden = true
        lblTitle.isHidden = true
        btnMe.isHidden = true
        lblButtom.isHidden = true
        btnAnonymous.isHidden = true
        vwBottomForDrag.isHidden = true
        
        lblComment.text = ""
        lblTitle.text = ""
    }
    
    func dragShow(){
        lblComment.isHidden = false
        lblTitle.isHidden = false
        lblButtom.isHidden = false
        btnAnonymous.isHidden = false
        vwBottomForDrag.isHidden = false
        btnMe.isHidden = false
    }
    
    //MARK:- Next ViewController
    func nextVC(){
            let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.interview) as! InterviewPreparationViewController
        vc.modelcourselist = selectedCourse.course_list
            vc.courseID = selectedCourse.course_id!
            vc.navigationTitle = selectedCourse.course_title!
            self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource Methods
extension LearningViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayListofCourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Learningcell", for: indexPath) as? LearningTableViewCell
        
        let modellearning = arrayListofCourse[indexPath.row]
        cell?.labelCourseTitle.text = modellearning.course_title
        cell?.labelShortDesc.text   = modellearning.course_short_desc
        cell?.labelDescription.text = modellearning.course_description
      
//        _ = refStorage.child("uploads/IMG_2161.jpg").getData(maxSize: 1 * 1024 * 1024, completion: { (dataImg, error) in
//            if error == nil{
//                cell?.imageView?.image = UIImage(data: dataImg!)
//            }
//        })
        cell?.selectionStyle = .none
        if modellearning.buy == "1" {
            cell?.imgBought.isHidden = true
        }else{
            cell?.imgBought.isHidden = false
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = arrayListofCourse[indexPath.row]
        if arrayListofCourse[indexPath.row].buy == "1"{
            self.nextVC()
        }else{
            self.showBuyAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Online
        if (segue.identifier == "Anonymous") {
            //   if self.strUserComment == "unKnown"{  //Anonymous
            let vc = segue.destination as! CommentVC
            _  = arrayListofCourse[dragedIndexPath.row]
            // vc.courseID = modellearning.comments_list?.course_id ?? ""
            vc.userID   = "0"
        }
        else if (segue.identifier == "apply"){
            print("Apply")
        }
        else{  //Me
            _ = segue.destination as! CommentVC
            _  = arrayListofCourse[dragedIndexPath.row]
            // vc.courseID = modellearning.comments_list?.course_id ?? ""
            //  vc.userID   = modellearning.comments_list?.user_id ?? ""
        }
    }
}
