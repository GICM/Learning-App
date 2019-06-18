//
//  FAQVC.swift
//  GICM
//
//  Created by Rafi on 09/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Instabug
import FirebaseStorage
import SDWebImage
import FirebaseFirestore
import Firebase
import ExpyTableView

class FAQVC: UIViewController,UITableViewDelegate,UITableViewDataSource,ExpyTableViewDataSource,ExpyTableViewDelegate {
   
    
   
    //MARK:- View Life Cycle
    @IBOutlet weak var tblFAQ: ExpyTableView!
    var strBody = "you can cheat the system but you cannot cheat yourself. ITS YOUR OWN RESPONSIBILITY TO Learn and achieve your goals. WE support you on that journey."
    
    var refStorage = Storage.storage().reference()
    var arrayFAQ : [FAQModel] = []
    var arrSearch : [FAQModel] = []
    
    
    @IBOutlet weak var btnLearning: UIButton!
    @IBOutlet weak var btnProductivity: UIButton!
    @IBOutlet weak var btnOthers: UIButton!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("***********************************************")
        NSLog(" FAQ VC View did load  ")
        
        Firestore.firestore().disableNetwork { (error) in
            self.getFAQFirebase()
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        configUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Local Methods
    func configUI(){
        
        self.btnLearning.setBottomBorder()
        self.btnProductivity.removeButtomBorder()
        self.btnOthers.removeButtomBorder()
        
        self.navigationController?.isNavigationBarHidden = true
        tblFAQ.rowHeight = UITableViewAutomaticDimension
        tblFAQ.delegate = self
        tblFAQ.dataSource = self
        tblFAQ.contentInset = UIEdgeInsets.zero
        
        self.tblFAQ.tableFooterView = UIView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK:- Button Action
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func learningAction(_ sender: UIButton) {
        self.btnLearning.setBottomBorder()
        self.btnProductivity.removeButtomBorder()
        self.btnOthers.removeButtomBorder()
        
        let currectTitle = sender.currentTitle
        self.getFAQDetails(strCategory: currectTitle!)
        
    }
    
    @IBAction func productivityAction(_ sender: UIButton) {
        self.btnProductivity.setBottomBorder()
        self.btnOthers.removeButtomBorder()
        self.btnLearning.removeButtomBorder()
        
        let currectTitle = sender.currentTitle
        self.getFAQDetails(strCategory: currectTitle!)
    }
    
    @IBAction func otherAction(_ sender: UIButton) {
        
        self.btnOthers.setBottomBorder()
        self.btnLearning.removeButtomBorder()
        self.btnProductivity.removeButtomBorder()
        
        let currectTitle = sender.currentTitle
        self.getFAQDetails(strCategory: currectTitle!)
    }
    
    //MARK:- Delegate Methods
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQHeaderCell") as! HeaderCell
        cell.labelPhoneName.text = arrSearch[section].title
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! FAQCell
        let index = indexPath.row
        let faqObj = arrSearch[index-1]
        cell.lblBody.text = faqObj.subject
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 65
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    //MARK:- FAQ API Integation
    func getFAQFirebase(){
        _ = FirebaseManager.shared.firebaseDP!.collection("FAQ").addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseIntoFAQ(snap:snap)
                self.tblFAQ.reloadData()
            }
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    
    func parseIntoFAQ(snap:[QueryDocumentSnapshot]){
        self.arrayFAQ.removeAll()
        for obj in snap{
            let model = FAQModel()
            model.title = obj["title"] as? String ?? ""
            model.subject = obj["subject"] as? String ?? ""
            model.category = obj["category"] as? String ?? ""
            self.arrayFAQ.append(model)
        }
        self.getFAQDetails(strCategory: "Learning")
    }
    
    func getFAQDetails(strCategory: String){
        self.arrSearch = self.arrayFAQ.filter({$0.category?.range(of: strCategory, options: [.diacriticInsensitive, .caseInsensitive]) != nil} )
        self.tblFAQ.reloadData()
    }
}


//MARK:- FAQ Model
class FAQModel{
    var title :String?
    var subject :String?
    var category :String?
}
