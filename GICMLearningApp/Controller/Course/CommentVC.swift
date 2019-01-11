//
//  CommentVC.swift
//  GICMLearningApp
//
//  Created by Rafi A on 06/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CommentVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    //MARK:- Initialization
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var tblComment: UITableView!
    
    
    var arrCommentList: [CommentDataFB] = []
    var courseID = "1"
    var userID = "0"
    var strFromVC = ""
    var postedDate = ""
    var strUserType = ""
    var refGetComments: AnyObject?
    //Multiple Comment
    var strListCommentAPIURL = ""
    var strAddCommentAPIURL  = ""
    
    var dictListComment = [String:Any]()
    var dictAddComment  = [String:Any]()
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblComment.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        tblComment.delegate = self
        tblComment.dataSource = self
        tblComment.contentInset = UIEdgeInsets.zero
        Utilities.leftGapView(txtComment)
        currentCommentList(list: strFromVC)
        getCommentsFirebase()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Local Methods
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        print("Add Comment Message")
        //  AddCommentISL()
        self.addCommentFirebase()
    }
    
    //MARK:- scroll Last Row
    func scrollToLastRow() {
        let indexPath = NSIndexPath(row: arrCommentList.count - 1, section: 0)//NSIndexPath(forRow: arrCommentList.count - 1, inSection: 0)
        self.tblComment.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
    }
    
    
    func getCommentsFirebase(){
        
        refGetComments!.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.parseIntoModel(snap: snap)
                self.tblComment.reloadData()
                self.scrollToLastRow()
            }
        })
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        self.arrCommentList.removeAll()
        for obj in snap{
            let model = CommentDataFB()
            model.comments = obj["comments"] as? String ?? ""
            model.course_id = obj["course_id"] as? String ?? ""
            model.posted_date = obj["posted_date"] as? String ?? ""
            model.type = obj["type"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            model.username = obj["username"] as? String ?? ""
            self.arrCommentList.append(model)
        }
        self.arrCommentList = self.arrCommentList.sorted(by: { (list1, list2) -> Bool in
            let date1 = self.getDateFromString(strDate: list1.posted_date!)
            let date2 = self.getDateFromString(strDate: list2.posted_date!)
            return date1 < date2
        })
        
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        return formatter.string(from: date)
    }
    func getDateFromString(strDate:String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        return formatter.date(from: strDate)!
    }
    
    func addCommentFirebase(){
        endEditing()
        postedDate = self.getCurrentDate()
        currentCommentList(list: strFromVC)
        let ref = FirebaseManager.shared.firebaseDP?.collection("comments")
        ref?.addDocument(data: dictAddComment, completion: { (error) in
            self.getCommentsFirebase()
            if self.strFromVC == "Learn" {
                let refC = FirebaseManager.shared.firebaseDP?.collection("course").document(self.courseID)
                refC?.updateData(["comments" : self.txtComment.text ?? ""], completion: { (error) in
                    self.txtComment.text = ""
                })
            }
            else{
                self.txtComment.text = ""
            }
        })
    }
    
    //MARK:- Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.arrCommentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! LearningTableViewCell
        let modelObj = arrCommentList[indexPath.row]
        cell.labelComment.text = modelObj.comments ?? ""
        cell.lblCommenterName.text = modelObj.username ?? "Anonymous"
        return cell
    }
    
    @IBAction func back(_ sender: Any) {
        if strFromVC == "Learn"{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


