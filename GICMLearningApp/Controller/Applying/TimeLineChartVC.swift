//
//  TimeLineChartVC.swift
//  GICM
//
//  Created by Rafi on 02/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TimeLineChartVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- Initialization
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblTimeLine: UITableView!
    
    @IBOutlet weak var btnProjectname: UIButton!
    
    var strProjectName = ""

    var arrAddMeetingList : [AddMeetingListFB] = []
    var projectID = ""
    var fromVC = ""
    
    var arrDatesString           : [String] = []
    var arrDatesDouble           : [Double] = []
    var arrYaxisValues     : [Double] = []
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configUI()
    }
    //MARK:-Local Methods
    func configUI(){
        tblTimeLine.rowHeight = UITableViewAutomaticDimension
        tblTimeLine.delegate = self
        tblTimeLine.dataSource = self
        tblTimeLine.contentInset = UIEdgeInsets.zero
        
        btnProjectname.setTitle(strProjectName, for: .normal)
        self.lblTitle.text = fromVC
        if fromVC == "Career timeline"{
            getAddCareerFB()
            }else{
            getAddMeetingFB()
        }
    }
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func chartVC(_ sender: Any) {
        
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "ChartVC") as! ChartVC
        nextVC.fromVC         = fromVC
        nextVC.arrDatesString       = arrDatesString
        nextVC.arrYaxisValues = arrYaxisValues
        nextVC.arrDatesDouble = arrDatesDouble
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK:- Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrAddMeetingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineChartCell", for: indexPath) as! TimeLineChartCell
        
            let modelObj = arrAddMeetingList[indexPath.row]
            cell.selectionStyle = .none
            let strPositive = (modelObj.positive).joined(separator: "\n\n")
            let strNegative = (modelObj.negative).joined(separator: "\n\n")
            
            cell.lblPositive.text = strPositive //arrNegative[indexPath.row]
            cell.lblNegative.text = strNegative //arrPositive[indexPath.row]
            cell.lblDate.text     = modelObj.date  //arrDate[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    //MARK:- List Of Add Meeting Api
    func getAddMeetingFB(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("add_meeting").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID()).whereField("project_id", isEqualTo: self.projectID)
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.parseIntoModel(snap: snap)
                self.arrYaxisValues = self.arrAddMeetingList.map({
                    Double($0.point!)
                })
                self.arrDatesString = self.arrAddMeetingList.map({
                    $0.date ?? ""
                })
                self.arrDatesDouble = self.arrAddMeetingList.map({ self.convert_decimal(dateString: $0.date ?? "")
                })
                self.tblTimeLine.reloadData()
                }
            print("get meeting api error: \(String(describing: error?.localizedDescription))")
            }
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        arrAddMeetingList.removeAll()
        for obj in snap{
            let model = AddMeetingListFB()
            model.date = obj["date"] as? String ?? "0"
            model.negative = obj["negative"] as? Array ?? []
            model.point = obj["point"] as? Int ?? 0
            model.positive = obj["positive"] as? Array ?? []
            model.project_id = obj["project_id"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            arrAddMeetingList.append(model)
        }
    }
   
    //MARK:- List Of Career Api
    func getAddCareerFB(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("project_career").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.parseIntoModel(snap: snap)
                self.arrYaxisValues = self.arrAddMeetingList.map({
                    Double($0.point!)
                })
                self.arrDatesString = self.arrAddMeetingList.map({
                    $0.date ?? ""
                })
                self.arrDatesDouble = self.arrAddMeetingList.map({ self.convert_decimal(dateString: $0.date ?? "")
                })
                self.tblTimeLine.reloadData()
            }
            print("get career api error: \(String(describing: error?.localizedDescription))")
        }
    }
}
