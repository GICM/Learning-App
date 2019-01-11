//
//  ApplyingListVC.swift
//  GICM
//
//  Created by Rafi on 26/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SwipeCellKit

class ApplyingListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    //MARK:- Initialization
    @IBOutlet weak var tblApplyingList: UITableView!
    var strProjectID = ""
    var arrProjectList : [ProjectModelFB] = []
    
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
        configUI()
    }
    
    //MARK:- Local Methods
    func configUI(){
        tblApplyingList.delegate = self
        tblApplyingList.dataSource = self
        tblApplyingList.contentInset = UIEdgeInsets.zero
        self.navigationController?.isNavigationBarHidden = true
        
        //  projectListISL()
        projectListISLFirebase()
    }
    
    //MARK:- Comment
    @IBAction func comment(_ sender: Any) {
        let alertController = UIAlertController(title: "Applying", message: "Enter a Comment", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            
            let field = textFields[0]
            // store your data
            print(field)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Comment"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProjectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applyingCell", for: indexPath) as! ApplyingCell
        let modelObj = arrProjectList[indexPath.row]
        cell.lblProjectName.text = modelObj.project_name!
        cell.lblProjectStatus.text = modelObj.date!
        //        cell.imgApplying.sd_setImage(with: URL(string: modelObj.project_image ?? ""), placeholderImage: UIImage(named: "noImage"))
        if let profileStr = modelObj.project_image, profileStr.count > 0{
            let dataDecoded : Data = Data(base64Encoded: profileStr)!
            cell.imgApplying.image = UIImage(data: dataDecoded)
        }else{
            cell.imgApplying.image = UIImage(named: "noImage")
        }
        cell.selectionStyle = .none
        cell.delegate = self as? SwipeTableViewCellDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did selected")
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC =  story.instantiateViewController(withIdentifier: "TrackingVC") as! TrackingVC
        
        let modelObj = arrProjectList[indexPath.row]
        nextVC.projectName     = modelObj.project_name!
        nextVC.projectID       = modelObj.project_id!
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK:- Show Alert
    func showDeleteAlert() {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Do you want to delete the project?", comment:""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            
            //Call Delete API
            //self.deleteProjectAPI()
            self.deleteProjectApiFirebase()
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    func projectListISLFirebase()
    {
        _ = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID()).addSnapshotListener({ (snapshot, error) in
            if let snap = snapshot?.documents {
                if snap.count > 0
                {
                    self.parseIntoModel(snap: snap)
                    self.tblApplyingList.reloadData()
                }
            }
        })
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        arrProjectList.removeAll()
        for obj in snap{
            let model = ProjectModelFB()
            model.client_name = obj["client_name"] as? String ?? ""
            model.date = obj["date"] as? String ?? ""
            model.end_date = obj["end_date"] as? String ?? ""
            model.meeting_point = obj["meeting_point"] as? String ?? "0"
            model.project_id = obj.documentID
            model.project_image = obj["project_image"] as? String ?? ""
            model.project_name = obj["project_name"] as? String ?? ""
            model.start_date = obj["start_date"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            arrProjectList.append(model)
        }
    }
    
    func deleteProjectApiFirebase(){
        
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(strProjectID)
        ref.delete { (error) in
            if error == nil{
                self.deleteAllChildRelatedProject()
                self.projectListISLFirebase()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Delete project failed,try again later", controller: self)
            }
        }
    }
    
    func deleteAllChildRelatedProject(){
        // delete add meeting related to project id
       let refAddMeeting=FirebaseManager.shared.firebaseDP!.collection("add_meeting").whereField("project_id", isEqualTo:self.strProjectID)
        refAddMeeting.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("add_meeting").document(doc.documentID).delete()
                }
            }
            
        })
        
        // delete project career related to project id
        
        let refProCareer=FirebaseManager.shared.firebaseDP!.collection("project_career").whereField("project_id", isEqualTo:self.strProjectID)
        refProCareer.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("project_career").document(doc.documentID).delete()
                }
            }
            
        })
        
        // delete value added related to project id
        
        let refValueAdded=FirebaseManager.shared.firebaseDP!.collection("value_added").whereField("project_id", isEqualTo:self.strProjectID)
        refValueAdded.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("value_added").document(doc.documentID).delete()
                }
            }
            
        })
        
        // delete work life balance related to project id
        
        let refWork=FirebaseManager.shared.firebaseDP!.collection("work_life_bal").whereField("project_id", isEqualTo:self.strProjectID)
        refWork.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                for doc in snap{
                    FirebaseManager.shared.firebaseDP!.collection("work_life_bal").document(doc.documentID).delete()
                }
            }
            
        })
    }
}

extension ApplyingListVC: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right{
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                print("Delete")
                let projectObj = self.arrProjectList[indexPath.row]
                self.strProjectID = projectObj.project_id!
                self.showDeleteAlert()
            }
            
            // customize the action appearance
            deleteAction.backgroundColor = UIColor.red
            deleteAction.textColor = UIColor.black
            return [deleteAction]
        }else{
            let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
                print("Edit")
                let nextVC =  self.storyboard?.instantiateViewController(withIdentifier: "AddProjectVC") as! AddProjectVC
                nextVC.fromVC = "edit"
                nextVC.projectModelObj = self.arrProjectList[indexPath.row]
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            editAction.backgroundColor = UIColor.yellow
            editAction.textColor = UIColor.black
            return [editAction]
        }
    }
}




