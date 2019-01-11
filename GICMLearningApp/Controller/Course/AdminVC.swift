//
//  AdminVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 20/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import LUExpandableTableView
import FirebaseFirestore
import FirebaseStorage



class AdminVC: UIViewController {
    
    @IBOutlet weak var tblAdmin: LUExpandableTableView!
    var arraySuggestionsHeaderTitle:[String] = ["Screen","Date","Comment","User","Delete"]
    var arraySuggestionsScreen = ["Profile","Profile","Profile","Invite"]
    var arraySuggestionsDate = ["1.1.2018","9.3.2018","11.3.2018","5.6.2018"]
    var arraySuggestionsComment = ["FB pic square","My pic not there","Add hobbies","Invite all function"]
    var arraySuggestionsUser = ["UserX","UserZ","UserY","UserX"]
    var arraySuggestionsDelete = ["","","",""]
    
    
    var arrayApprovalHeaderTitle:[String] = ["Reject","Screen","Date","Type of upload","User","Delete"]
    var arrayApprovalScreen = ["Applying","Applying","Learning","profile"]
    var arrayApprovalDate = ["1.1.2018","9.3.2018","11.3.2018","5.6.2018"]
    var arrayApprovalComment = ["Translation French","Improvement","Translation German","Alternative video"]
    var arrayApprovalUser = ["UserX","UserZ","UserY","UserX"]
    var arrayApprovalDelete = ["","","",""]
    var arrayApprovalReject = ["","","",""]
    
    var arrayCallHeaderTitle:[String] = ["Next","Type","Date","Request status","User","Delete"]
    var arrayCallScreen = ["Expert","Review","Proposal","Proposal"]
    var arrayCallDate = ["1.1.2018","9.3.2018","11.3.2018","5.6.2018"]
    var arrayCallComment = ["Open","Open","Quote send","Payment recieved"]
    var arrayCallUser = ["UserX","UserZ","UserY","UserX"]
    var arrayCallDelete = ["","","",""]
    var arrayCallReject = ["","","",""]
    let sectionHeaderReuseIdentifier =  "AdminHeaderTitleSectionHeader"
    let cellReuseIdentifier =  "AdminSubHeadingCell"
    
    var arraySectionHeader:[String] = ["SUGGESTIONS","APPROVAL","CALL4BACKUP"]
    var isFirstTimeLoaded = false
    
    
     var arrayRequest : [Call4BackupModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblAdmin.register(UINib(nibName: "AdminSubHeadingCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tblAdmin.register(UINib(nibName: "AdminHeaderTitleSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)
        tblAdmin.tableFooterView = UIView()
        tblAdmin.separatorStyle = .none
        tblAdmin.expandableTableViewDelegate = self
        tblAdmin.expandableTableViewDataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        getCall4Backup()
    }
    
    //MARK:- call4backup API
    func getCall4Backup(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("call_backup").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID())
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.parseIntoModel(snap: snap)
                self.tblAdmin.reloadData()
            }
        })
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        self.arrayRequest.removeAll()
        for obj in snap{
            let model = Call4BackupModel()
            model.mode = obj["mode"] as? String ?? ""
            model.date = obj["date"] as? String ?? ""
            model.urgency = obj["urgency"] as? String ?? ""
            model.title = obj["title"] as? String ?? ""
            model.details = obj["details"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            model.user_name = obj["user_name"] as? String ?? ""
            model.doc_size = obj["docs_size"] as? UInt64 ?? 0
            model.doc_url = obj["docs_url"] as? String ?? ""
            model.status = obj["status"] as? String ?? ""
            model.doc_id = obj["doc_id"] as? String ?? ""
            self.arrayRequest.append(model)
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        let tag = sender?.view?.tag
        print(tag)
      //  self.deletCall4Bakcup(tag: (sender?.view?.tag)!)
        showLogoutAlert(tagValue : tag!)
    }
    
    
    func showLogoutAlert(tagValue : Int) {
        let alertController = UIAlertController(title: "Attention!", message: NSLocalizedString("Are you sure you want to Delete?", comment:""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
           self.deletCall4Bakcup(tag: tagValue)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.navigationController?.present(alertController, animated: true, completion:nil)
    }
    
    func deletCall4Bakcup(tag:Int){
        let ref = FirebaseManager.shared.firebaseDP?.collection("call_backup").whereField("doc_id", isEqualTo:  arrayRequest[tag].doc_id!)
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                let ref2 = FirebaseManager.shared.firebaseDP?.collection("call_backup").document(snap[0].documentID)
                ref2?.delete(completion: { (error) in
                    if error == nil{
                        self.deleteZipfileInStorage(filename:snap[0].get("doc_id") as! String)
                    }
                    else{
                        WebserviceManager.shared.hideMBProgress(view: self.view)
                    }
                })
            }
        })
    }
    
    func deleteZipfileInStorage(filename:String){
        let refStorage = Storage.storage().reference().child("call4backup").child("\(filename).zip")
        refStorage.delete { (error) in
            if error == nil {
                WebserviceManager.shared.hideMBProgress(view: self.view)
                self.getCall4Backup()
            }
            else{
                WebserviceManager.shared.hideMBProgress(view: self.view)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for i in 0..<3 {
            if let header = tblAdmin.tableView(tblAdmin, viewForHeaderInSection: i) as? AdminHeaderTitleSectionHeader{
                header.initialSetup(header: header, index: i)
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        let transition:CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - LUExpandableTableViewDataSource

extension AdminVC: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return 3
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2{
            return arrayRequest.count + 1
        }else{
            return 5
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? AdminSubHeadingCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.lblScreen.font = UIFont.boldSystemFont(ofSize: 10.0)
            cell.lblDate.font = UIFont.boldSystemFont(ofSize: 10.0)
            cell.lblComment.font = UIFont.boldSystemFont(ofSize: 10.0)
            cell.lblUser.font = UIFont.boldSystemFont(ofSize: 10.0)
            cell.lblDelete.font = UIFont.boldSystemFont(ofSize: 10.0)
            cell.lblReject.font = UIFont.boldSystemFont(ofSize: 10.0)
        }
        
        if indexPath.section == 0 {
            cell.lblReject.text = ""
            cell.constraintCommentLbl.constant = 25
            if indexPath.row == 0 {
                cell.imgScreen.image = #imageLiteral(resourceName: "Down_arrow_Gray")
                cell.imgScreen.tintColor = UIColor.darkGray
                cell.imgDate.image = #imageLiteral(resourceName: "Down_arrow_white")
                cell.imgUser.image = #imageLiteral(resourceName: "Up_arrow_Gray")
                cell.imgDelete.image = UIImage()
                cell.imgReject.image = UIImage()
                
                cell.lblScreen.text = arraySuggestionsHeaderTitle[0]
                cell.lblDate.text = arraySuggestionsHeaderTitle[1]
                cell.lblComment.text = arraySuggestionsHeaderTitle[2]
                cell.lblUser.text = arraySuggestionsHeaderTitle[3]
                cell.lblDelete.text = arraySuggestionsHeaderTitle[4]
                
                return cell
            } else {
                
                 cell.imgScreen.image = UIImage()
                 cell.imgDate.image = UIImage()
                 cell.imgUser.image = UIImage()
                cell.imgDelete.image = #imageLiteral(resourceName: "close")
                cell.lblScreen.text = arraySuggestionsScreen[indexPath.row-1]
                cell.lblDate.text = arraySuggestionsDate[indexPath.row-1]
                cell.lblComment.text = arraySuggestionsComment[indexPath.row-1]
                cell.lblUser.text = arraySuggestionsUser[indexPath.row-1]
                cell.lblDelete.text = arraySuggestionsDelete[indexPath.row-1]
                return cell
            }
            
            
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.imgScreen.image = #imageLiteral(resourceName: "Down_arrow_white")
                cell.imgDate.image = #imageLiteral(resourceName: "Down_arrow_Gray")
                cell.imgDate.tintColor = UIColor.darkGray
                cell.imgUser.image = #imageLiteral(resourceName: "Down_arrow_Gray")
                cell.imgUser.tintColor = UIColor.darkGray
                  cell.imgDelete.image = UIImage()

                 cell.imgReject.image = UIImage()
                cell.lblReject.text = arrayApprovalHeaderTitle[0]
                cell.lblScreen.text = arrayApprovalHeaderTitle[1]
                cell.lblDate.text = arrayApprovalHeaderTitle[2]
                cell.lblComment.text = arrayApprovalHeaderTitle[3]
                cell.lblUser.text = arrayApprovalHeaderTitle[4]
                cell.lblDelete.text = arrayApprovalHeaderTitle[5]
                return cell
            } else {
                  cell.imgScreen.image = UIImage()
                  cell.imgDate.image = UIImage()
                  cell.imgUser.image = UIImage()
                cell.imgReject.image = #imageLiteral(resourceName: "close")
                cell.imgDelete.image = #imageLiteral(resourceName: "select")
                cell.lblReject.text = "Reject"
                cell.lblReject.isHidden = true
                cell.lblScreen.text = arrayApprovalScreen[indexPath.row-1]
                cell.lblDate.text = arrayApprovalDate[indexPath.row-1]
                cell.lblComment.text = arrayApprovalComment[indexPath.row-1]
                cell.lblUser.text = arrayApprovalUser[indexPath.row-1]
                cell.lblDelete.text = arrayApprovalDelete[indexPath.row-1]
                
               
                
                return cell
            }
        } else {
            if indexPath.row == 0 {
                cell.imgScreen.image = #imageLiteral(resourceName: "Down_arrow_white")
                cell.imgDate.image = #imageLiteral(resourceName: "Down_arrow_Gray")
                cell.imgDate.tintColor = UIColor.darkGray
                cell.imgUser.image = #imageLiteral(resourceName: "Down_arrow_Gray")
                cell.imgUser.tintColor = UIColor.darkGray
                  cell.imgDelete.image = UIImage()
                cell.lblReject.text = arrayCallHeaderTitle[0]
                cell.lblScreen.text = arrayCallHeaderTitle[1]
                cell.lblDate.text = arrayCallHeaderTitle[2]
                cell.lblComment.text = arrayCallHeaderTitle[3]
                cell.lblUser.text = arrayCallHeaderTitle[4]
                cell.lblDelete.text = arrayCallHeaderTitle[5]
                return cell
            } else {
                
                cell.imgScreen.image = UIImage()
                cell.imgDate.image = UIImage()
                cell.imgUser.image = UIImage()
                cell.imgDelete.image = #imageLiteral(resourceName: "close")
                cell.lblDelete.text  = ""
                cell.lblUser.text = ""
                cell.lblDate.text = arrayRequest[indexPath.row-1].date ?? ""
                cell.lblComment.text = arrayRequest[indexPath.row-1].status ?? ""
                cell.lblScreen.text = arrayRequest[indexPath.row-1].title ?? ""
                
                cell.imgDelete.tag = indexPath.row-1
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                cell.imgDelete.addGestureRecognizer(tap)
                
//                cell.lblScreen.text = arrayCallScreen[indexPath.row-1]
//                cell.lblDate.text = arrayCallDate[indexPath.row-1]
//                cell.lblComment.text = arrayCallComment[indexPath.row-1]
//                cell.lblUser.text = arrayCallUser[indexPath.row-1]
//                cell.lblDelete.text = arrayCallDelete[indexPath.row-1]
                return cell
            }
        }
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as? AdminHeaderTitleSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }
        
        sectionHeader.label.text = arraySectionHeader[section]
        
        
        return sectionHeader
    }
    
}

// MARK: - LUExpandableTableViewDelegate

extension AdminVC: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        if indexPath.row == 0 {
            return 35
        }
        return 30
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        /// Returning `UITableViewAutomaticDimension` value on iOS 9 will cause reloading all cells due to an iOS 9 bug with automatic dimensions
        
        return 45
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select cection header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
    
}
