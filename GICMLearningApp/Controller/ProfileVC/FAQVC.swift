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

class FAQVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
   
    //MARK:- View Life Cycle
    @IBOutlet weak var tblFAQ: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var strBody = "you can cheat the system but you cannot cheat yourself. ITS YOUR OWN RESPONSIBILITY TO Learn and achieve your goals. WE support you on that journey."
    
    var refStorage = Storage.storage().reference()
    var arrayFAQ : [FAQModel] = []
    var arrSearch : [FAQModel] = []
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigationController?.isNavigationBarHidden = true
        tblFAQ.rowHeight = UITableViewAutomaticDimension
        tblFAQ.delegate = self
        tblFAQ.dataSource = self
        tblFAQ.contentInset = UIEdgeInsets.zero
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
    
    @IBAction func FAQType(_ sender: Any) {
        print(segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex) ?? "")
        let categoryName = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
        self.getFAQDetails(strCategory: categoryName!)
    }
    
    //MARK:- Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! FAQCell
        let faqObj = arrSearch[indexPath.row]
        cell.lblTitle.text = faqObj.title
        cell.lblBody.text = faqObj.subject
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        segmentControl.selectedSegmentIndex = 0
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
