//
//  CreateVC.swift
//  GICM
//
//  Created by Rafi on 09/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import WebKit
import FirebaseStorage
import FirebaseFirestore

class ReleaseNotesVC:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var lblVersion: UILabel!
    var arrHeading: [String] = []
    var arrData: [String] = []
    
    @IBOutlet weak var tblRelease: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("***********************************************")
        NSLog("Release Notes View Controller View did load  ")
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        print("\(appVersion)")
        self.lblVersion.text = "Version \(appVersion ?? "0.55")"
      // self.createReleaseNotesJSON()
        Firestore.firestore().disableNetwork { (error) in
            self.getReleaseListFirebase()
        }
       
        tblRelease.rowHeight = UITableViewAutomaticDimension
        tblRelease.delegate = self
        tblRelease.dataSource = self
        tblRelease.contentInset = UIEdgeInsets.zero
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    func getReleaseListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("release")
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0
            {
                self.parseIntoReleaseNotes(snap:snap)
                self.tblRelease.reloadData()
            }
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    
    func parseIntoReleaseNotes(snap:[QueryDocumentSnapshot]){
      //  self.arrayListofCourse.removeAll()
        for obj in snap{
            let version = obj["version"] as? [String] ?? []
            let feedback = obj["feedback"] as? [String] ?? []

            self.arrData = feedback
            self.arrHeading = version
        }
        arrHeading.reverse()
        arrData.reverse()
        self.tblRelease.reloadData()
        
    }
    
//    func webViewConfig(){
//        //webView.isHidden = true
//        let refStorage = Storage.storage().reference().child("releasenotes").child("releaseNotes.html")
//        refStorage.downloadURL(completion: {url,error in
//
//            if error == nil{
//                print("URL \(String(describing: url))")
//                let downloadURL = String(describing: url)
//
//                let requestObj = URLRequest(url: url!)
//                self.webView.loadRequest(requestObj)
//            }})
//    }
      
    func createReleaseNotesJSON()
    {
         var jsonCompany : Any?
        if let path = Bundle.main.path(forResource: "ReleaseNotes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                jsonCompany = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                let refCompany2 = FirebaseManager.shared.firebaseDP!.collection("release")
                refCompany2.addDocument(data: jsonCompany as! [String : Any], completion: { (error) in
                    print("the create company error:\(error.debugDescription)")
                })
            } catch {
                // handle error
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHeading.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "release", for: indexPath) as! LearningTableViewCell
        
        let heading = arrHeading[indexPath.row]
        cell.lblVersion.text = "   \(heading)"
        cell.selectionStyle = .none
        cell.lblReleaseNotes.text = arrData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
