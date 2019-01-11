//
//  YourInviteVC.swift
//  GICM
//
//  Created by Rafi on 19/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Instabug

class YourInviteVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- Initialization
    @IBOutlet weak var tblYourInvites: UITableView!
    @IBOutlet weak var btnPending: UIButton!
    @IBOutlet weak var btnEarned: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    var strInvite = "invite"
    var arrContactName : [InviteModel] = []
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if strInvite ==  "invite"{
            self.highlightPending()
            self.getInvites(status: "invite")
        }
        else{
            self.highlightEarn()
            self.getInvites(status: "earn")
        }
      NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tblYourInvites.tableFooterView = UIView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.isShowMenu = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInvites(status:String){
        let ref = FirebaseManager.shared.firebaseDP?.collection("invite").whereField("user_id", isEqualTo: UserDefaults.standard.getUserID()).whereField("status", isEqualTo: status)
        ref?.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.lblStatus.isHidden = true
                self.tblYourInvites.isHidden = false
                self.parseIntoModel(snap: snap)
                self.tblYourInvites.reloadData()
            }
        })
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        self.arrContactName.removeAll()
        for obj in snap{
            let model = InviteModel(inviteId: obj.get("invite_id") as? String ?? "", invitedBy: obj.get("invitedBy") as? String ?? "", inviteMail: obj.get("invitedMail") as? String ?? "", invitedName: obj.get("invitedName") as? String ?? "", inviteStatus: obj.get("status") as? String ?? "", inviteUserID: obj.get("user_id") as? String ?? "", inviteUserName: obj.get("user_name") as? String ?? "")
            self.arrContactName.append(model)
        }
    }
    //MARK:- Button Action
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func inviteMore(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pending(_ sender: Any) {
        self.getInvites(status: "invite")
        self.highlightPending()
    }
    
    func highlightPending(){
        self.btnPending.backgroundColor = UIColor.init(red: 97.0/255.0, green: 210.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        self.btnEarned.backgroundColor = UIColor.black
        lblStatus.isHidden = true
        tblYourInvites.isHidden = false
    }
    
    @IBAction func earned(_ sender: Any) {
        self.getInvites(status: "earn")
        self.highlightEarn()
    }
    
    func highlightEarn(){
        self.btnEarned.backgroundColor = UIColor.init(red: 97.0/255.0, green: 210.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        self.btnPending.backgroundColor = UIColor.black
        lblStatus.isHidden = false
        tblYourInvites.isHidden = true
    }
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrContactName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "yourInvites", for: indexPath) as! LearningTableViewCell
        cell.lblCommenterName.text = arrContactName[indexPath.row].invitedName
        cell.lblProjectPoints.text = arrContactName[indexPath.row].inviteMail
        
        cell.selectionStyle = .none
        return cell
    }
}
