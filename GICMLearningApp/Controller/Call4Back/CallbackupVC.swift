//
//  Call4backupVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 20/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CallbackupVC: UIViewController {

    @IBOutlet weak var tblCall4Back: UITableView!
    var arraySubTitle = ["Type","Date","Request status", "Delete"]
    var arrayRequest : [Call4BackupModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblCall4Back.register(UINib(nibName: "CallbackupCell", bundle: nil), forCellReuseIdentifier: "CallbackupCell")
        tblCall4Back.tableFooterView = UIView()
        tblCall4Back.separatorStyle = .none
        tblCall4Back.delegate = self
        tblCall4Back.dataSource = self
        tblCall4Back.contentInset = UIEdgeInsets.zero
    }
    override func viewWillAppear(_ animated: Bool) {
        getCall4Backup()
    }
    
    func getCall4Backup(){
        let ref = FirebaseManager.shared.firebaseDP?.collection("call_backup").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID())
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.parseIntoModel(snap: snap)
                self.tblCall4Back.reloadData()
            }
            else{
                self.arrayRequest.removeAll()
                self.tblCall4Back.reloadData()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func AddCallBackUp(_ sender: Any) {
        let story = UIStoryboard(name: "CallBackupStoryboard", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "call4BackupVC") as! call4BackupVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
    WebserviceManager.shared.showMBProgress(view: self.view)

    self.deletCall4Bakcup(tag: (sender?.view?.tag)!)
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
}

extension CallbackupVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
            
        }
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return arrayRequest.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallbackupCell", for: indexPath) as! CallbackupCell
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.imgDate.image = #imageLiteral(resourceName: "Down_arrow_Gray")
            cell.imgType.image = #imageLiteral(resourceName: "Down_arrow_Gray")
            cell.imgType.tintColor = UIColor.black
            cell.imgDate.tintColor = UIColor.darkGray
            cell.lblType.text = arraySubTitle[0]
            cell.lblDate.text = arraySubTitle[1]
            cell.lblRequestState.text = arraySubTitle[2]
            cell.lblDelete.text = arraySubTitle[3]
            
            
            cell.lblType.font =  UIFont.boldSystemFont(ofSize: 13.0)
            cell.lblDate.font =  UIFont.boldSystemFont(ofSize: 13.0)
            cell.lblRequestState.font =  UIFont.boldSystemFont(ofSize: 13.0)
            cell.lblDelete.font =  UIFont.boldSystemFont(ofSize: 13.0)
            cell.imgDelete.image = UIImage()
        } else {
            cell.imgDate.image = UIImage()
            cell.imgType.image = UIImage()
            cell.lblType.text = arrayRequest[indexPath.row-1].title
            cell.lblDate.text = arrayRequest[indexPath.row-1].date
            cell.lblRequestState.text = arrayRequest[indexPath.row-1].status
            cell.lblDelete.text = ""
            cell.imgDelete.image = #imageLiteral(resourceName: "close")
            cell.imgDelete.tag = indexPath.row-1
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            cell.imgDelete.addGestureRecognizer(tap)

        }
        return cell
    }
    
  
    
}
