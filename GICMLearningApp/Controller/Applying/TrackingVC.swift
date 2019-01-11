//
//  TrackingVC.swift
//  GICM
//
//  Created by Rafi on 27/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Instabug

class TrackingVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    //MARK:- Initialization
    @IBOutlet weak var tblPopup: UITableView!
    @IBOutlet weak var tblTracking: UITableView!
    @IBOutlet var vwPopup: UIView!
    @IBOutlet weak var lblPopStatus: UILabel!
    
    // Value Added and Work Life Balance
    var strProjectIDForMeeting = ""
    var projectID   = ""
    var projectName = ""
    var strWork   = ""
    var strStress_level = ""
    var strRelaxation   = ""
    var strSleep = ""
    
    var arrHeaderName = ["Career","Work Life Balance","Project"]
    var arrPopUpData: Array<[String:Any]> = []
    var valueRate = 0
    var type = ""
    var fromMethod = ""
    var strCareerLevel = "Senior consultant"
    
    var strCareervalue      = 0
    var strCareerPositive = 0
    var strCareerNegative = 0
    
    var selectedIndexPathText       : IndexPath!  = IndexPath(row: -1, section: 0)
    var arrChoosedText      : Array<String> = []
    var strTotalPoints = 0
    var strTotalPointsRef = 0
    
    let userId = UserDefaults.standard.getUserUUID()
    var arrayCareerLevel : [String] = []
    var arrProjectList : [ProjectModelFB] = []
    var arrComapnyList = [CompanyListFB]()
    var arrPostingList = [PostingListFB]()
    var jsonCompany : Any?
    var arrayCompanies : [[String:AnyObject]] = []
    var arrCompanyName = [String]()
    var strCompanyName = "Company Name"
    var companyID = ""
    var strPostingName = "Job Role"
    var PostingID = ""
    var trackingFb : QueryDocumentSnapshot?
    
    
    //Comment
    var customCommentObj     : CustomCommentVC!
    var a = 0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomCommentInstance()
        // Do any additional setu p after loading the view.
        NotificationCenter.default.post(name: Notification.Name("NotifyHideMenu"), object: nil, userInfo: nil)
        Utility.sharedInstance.isShowMenu = false
        self.configUI()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utility.sharedInstance.isShowMenu = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        tblTracking.delegate = self
        tblTracking.dataSource = self
        tblTracking.contentInset = UIEdgeInsets.zero
        tblTracking.decelerationRate = UIScrollViewDecelerationRateFast
        tblTracking.register(UINib(nibName: "ValueAddedCell", bundle: nil), forCellReuseIdentifier: "ValueAddedCell")
        tblTracking.register(UINib(nibName: "projectRateCell", bundle: nil), forCellReuseIdentifier: "projectRateCell")
        tblTracking.register(UINib(nibName: "CareerCell", bundle: nil), forCellReuseIdentifier: "CareerCell")
        tblTracking.register(UINib(nibName: "WorkCell", bundle: nil), forCellReuseIdentifier: "WorkCell")
        self.vwPopup.frame = self.view.frame
        self.vwPopup.isHidden = true
        self.view.addSubview(vwPopup)
    }
    
    //MARK:- Local Methods
    func configUI(){
        Firestore.firestore().disableNetwork { (error) in
            self.getCompanyDetail()
            self.projectListISLFirebase()
            self.getTrackingFB()
        }
    }
    
    //MARK:- Button Action
    
    //MARK:- Comment
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Up Value rate
    @objc func upAction(sender: UIButton!) {
        valueRate += 50
        self.tblTracking.reloadData()
    }
    
    //Down Value rate
    @objc func downAction(sender: UIButton!) {
        valueRate -= 50
        self.tblTracking.reloadData()
    }
    
    //Project Pop up
    @objc func plusProjectRate(sender: UIButton!) {
        removeAllSelected()
        lblPopStatus.text = "Positive"
        type = "positive"
        fromMethod = "addMeeting"
        //        arrPopUpData = ["Phase concluded","Client praise","Delivery Signoff","Client socializing","Positive referenced","Positive 1st Impression"]
        
        
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let indexPath = self.tblTracking.indexPathForRow(at: buttonPostion)
        let rowIndex =  indexPath?.row
        
        let arrDict = arrProjectList[rowIndex!]
        strProjectIDForMeeting = arrDict.project_id!
        
        let dict = [
            ["value": 50,
             "data":"Phase concluded"],
            ["value": 40,
             "data":"Client praise"],
            ["value": 30,
             "data":"Delivery Signoff"],
            ["value": 10,
             "data":"Client socializing"],
            ["value": 20,
             "data":"Positive referenced"],
            ["value": 5,
             "data":"Positive 1st Impression"]
        ]
        arrPopUpData = dict
        
        self.tblPopup.reloadData()
        self.vwPopup.isHidden = false
    }
    
    @objc func minusProjectRate(sender: UIButton!) {
        removeAllSelected()
        lblPopStatus.text = "Negative"
        type = "negative"
        fromMethod = "addMeeting"
        
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let indexPath = self.tblTracking.indexPathForRow(at: buttonPostion)
        let rowIndex =  indexPath?.row
        
        let arrDict = arrProjectList[rowIndex!]
        strProjectIDForMeeting = arrDict.project_id!
        
        let dict = [
            ["value": -100,
             "data":"Unwilling sacrificed"],
            ["value": -40,
             "data":"Client critic"],
            ["value": -20,
             "data":"Emotional Outbreak"],
            ["value": -20,
             "data":"Negative referenced"],
            ["value": -5,
             "data":"Negative 1st Impression"]
        ]
        arrPopUpData = dict
        self.tblPopup.reloadData()
        self.vwPopup.isHidden = false
    }
    
    //Career Popup
    @objc func plusCareer(sender: UIButton!) {
        removeAllSelected()
        
        lblPopStatus.text = "Positive"
        type = "positive"
        fromMethod = "Career"
        //  arrPopUpData = ["New project/client won","Press Release","Boss praise","Project extended "," Internal Publication"," Proposal delivered","Colleague praise"]
        
        let dict = [
            ["value": 100,
             "data":"New project/client won"],
            ["value": 100,
             "data":"Press Release"],
            ["value": 40,
             "data":"Boss praise"],
            ["value": 40,
             "data":"Project extended"],
            ["value": 20,
             "data":"Internal Publication"],
            ["value": 20,
             "data":"Proposal delivered"],
            ["value": 10,
             "data":"Colleague praise"]
        ]
        arrPopUpData = dict
        
        self.tblPopup.reloadData()
        self.vwPopup.isHidden = false
    }
    @objc func minusCarrer(sender: UIButton!) {
        removeAllSelected()
        
        lblPopStatus.text = "Negative"
        type = "negative"
        fromMethod = "Career"
        //  arrPopUpData = [" Early project departure","Boss critic","Negative performance","Colleague critic"]
        
        let dict = [
            ["value": -100,
             "data":"Early project departure"],
            ["value": -40,
             "data":"Boss critic"],
            ["value": -30,
             "data":"Negative performance"],
            ["value": -10,
             "data":"Colleague critic"]
        ]
        arrPopUpData = dict
        self.tblPopup.reloadData()
        self.vwPopup.isHidden = false
    }
    
    @objc func TimeLineChartProject(sender: UIButton!) {
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "TimeLineChartVC") as! TimeLineChartVC
        
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let indexPath = self.tblTracking.indexPathForRow(at: buttonPostion)
        let rowIndex =  indexPath?.row
        
        let arrDict = arrProjectList[rowIndex!]
        strProjectIDForMeeting = arrDict.project_id!
        
        nextVC.projectID = arrDict.project_id!
        nextVC.fromVC = "Project timeline"
        nextVC.strProjectName = arrDict.project_name!
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func TimeLineChartCareer(sender: UIButton!) {
        
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        
        let nextVC = story.instantiateViewController(withIdentifier: "TimeLineChartVC") as! TimeLineChartVC
        nextVC.projectID = projectID
        nextVC.fromVC = "Career timeline"
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //Work life balance
    @IBAction func sliderWorkAction(_ sender: UISlider) {
        print(sender.value)
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let cellIndexPath = self.tblTracking.indexPathForRow(at: pointInTable)
        //  let value = Int((sender.value * 24) + 0.5)
        
        let value = Int(sender.value)
        
        strWork = "\(value)"
        let cell = tblTracking.cellForRow(at: cellIndexPath!) as? WorkCell
        cell!.lblWork.text = "\(value) hrs"
        
        let work = Int(strWork)
        let relax = Int(strRelaxation)
        cell?.setBalancingImage(work: work ?? 0, relax: relax ?? 0)
        
        //        print(sender.value)
        //        if let cell = sender.superview?.superview as? WorkLifeBalanceCell{
        //            let value = Int((sender.value * 24) + 0.5)
        //            strWork = "\(value)"
        //            cell.lblWork.text = "\(value) hrs"
        //        }
    }
    @IBAction func sliderStressLevelAction(_ sender: UISlider) {
        
        print(sender.value)
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let cellIndexPath = self.tblTracking.indexPathForRow(at: pointInTable)
        //  let value = Int((sender.value * 24) + 0.5)
        let value = Int(sender.value)
        strStress_level = "\(value)"
        let cell = tblTracking.cellForRow(at: cellIndexPath!) as? WorkCell
        cell?.lblStress.text = "\(value) hrs"
        
        //        print(sender.value)
        //        if let cell = sender.superview?.superview as? WorkLifeBalanceCell{
        //            let value = Int((sender.value * 24) + 0.5)
        //            strStress_level = "\(value)"
        //            cell.lblStress.text = "\(value) hrs"
        //
        //        }
    }
    @IBAction func sliderRelaxAction(_ sender: UISlider) {
        print(sender.value)
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let cellIndexPath = self.tblTracking.indexPathForRow(at: pointInTable)
        //let value = Int((sender.value * 24) + 0.5)
        
        let value = Int(sender.value)
        strRelaxation = "\(value)"
        let currentCell = tblTracking.cellForRow(at: cellIndexPath!) as? WorkCell
        currentCell?.lblRelax.text = "\(value) hrs"
        
        let work = Int(strWork)
        let relax = Int(strRelaxation)
        currentCell?.setBalancingImage(work: work ?? 0, relax: relax ?? 0)
        
        //        if let cell = sender.superview?.superview as? WorkLifeBalanceCell{
        //            let value = Int((sender.value * 24) + 0.5)
        //            strRelaxation = "\(value)"
        //            cell.lblRelax.text = "\(value) hrs"
        //
        //        }
        
        
    }
    @IBAction func sliderSleepAction(_ sender: UISlider) {
        
        print(sender.value)
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblTracking)
        let cellIndexPath = self.tblTracking.indexPathForRow(at: pointInTable)
        // let value = Int((sender.value * 24) + 0.5)
        
        let value = Int(sender.value)
        strSleep = "\(value)"
        let cell = tblTracking.cellForRow(at: cellIndexPath!) as? WorkCell
        cell?.lblSleep.text = "\(value) hrs"
        
        //        if let cell = sender.superview?.superview as? WorkLifeBalanceCell{
        //            let value = Int((sender.value * 24) + 0.5)
        //            strSleep = "\(value)"
        //            cell.lblSleep.text = "\(value) hrs"
        //        }
    }
    
    //Value Added
    @objc func saveValue(sender: UIButton!) {
        // valueAddedAPI()
        valueAddedSaveApiFirebase()
    }
    
    @objc func valueAddedChart(sender: UIButton!) {
        print("Value Added Chart")
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "ValueAddedChartVC") as! ValueAddedChartVC
        nextVC.projectID = projectID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func workLifeBalance(sender: UIButton!) {
        print("Value Added Chart")
        let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
        let nextVC = story.instantiateViewController(withIdentifier: "WorkBalanceChartVC") as! WorkBalanceChartVC
        nextVC.projectID = projectID
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func SaveWorkLifeBalance(sender: UIButton!) {
        // self.addWorkLifeBalanceAPI()
        self.addWorkLifeBalanceFirebase()
    }
    
    @IBAction func cancelPopup(_ sender: Any) {
        self.vwPopup.isHidden = true
        removeAllSelected()
    }
    
    @IBAction func savePopUpValues(_ sender: Any){
        if fromMethod == "addMeeting"{
            print("addMeeting")
            self.tblTracking.reloadData()
            self.addMeetingAPIFirebase()
        }else{
            print("Career")
            self.strCareervalue += self.strTotalPoints
            self.tblTracking.reloadData()
            self.addCareerFirebase()
        }
        self.vwPopup.isHidden = true
        
        // removeAllSelected()
    }
    
    func removeAllSelected(){
        self.arrChoosedText.removeAll()
        self.strTotalPoints = 0
    }
    
    //MARK:- Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblTracking{
            
            if section == 2{  // Project list
                return self.arrProjectList.count
            }else{
                return 1
            }
        }else{
            return arrPopUpData.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == tblTracking{
            return arrHeaderName.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblTracking{
            //            if indexPath.section == 0{
            //                //Value Added
            //                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueAddedCell", for: indexPath) as! ValueAddedCell
            //                cell.lblDay.text = "Today"
            //                cell.selectionStyle = .none
            //                cell.txtRate.text = "\(valueRate)"
            //                cell.txtRate.delegate = self
            //                cell.txtRate.tag = 1
            //                cell.btnUp.addTarget(self, action: #selector(upAction), for: .touchUpInside)
            //                cell.btnDown.addTarget(self, action: #selector(downAction), for: .touchUpInside)
            //                cell.btnValueAdded.addTarget(self, action: #selector(valueAddedChart), for: .touchUpInside)
            //                cell.btnSave.addTarget(self, action: #selector(saveValue), for: .touchUpInside)
            //                return cell
            //            }
            if indexPath.section == 0{
                //Career
                let cell = tableView.dequeueReusableCell(withIdentifier: "CareerCell", for: indexPath) as! CareerCell
                cell.selectionStyle = .none
                cell.setBalancingImage(value: strCareervalue)
                cell.lblNegative.text = String(self.strCareerNegative)
                cell.lblPositive.text = String(self.strCareerPositive)
                cell.btnCareerPlus.addTarget(self, action: #selector(plusCareer), for: .touchUpInside)
                cell.btnCareerMinus.addTarget(self, action: #selector(minusCarrer), for: .touchUpInside)
                cell.btnCareer.addTarget(self, action: #selector(TimeLineChartCareer), for: .touchUpInside)
                //                cell.lblCarrerLevel.text = "Consulting Company : \(strCompanyName)"
                //                setLadderButton(cell:cell)
                //
                //                let totalLaddarButtonWidth = CGFloat((arrayCareerLevel.count*100) + 30)
                //                let screenWidth = self.view.frame.width
                //                var extraSpaceForScroll:CGFloat = 0
                //                if totalLaddarButtonWidth > screenWidth {
                //                    extraSpaceForScroll = totalLaddarButtonWidth - screenWidth
                //                } else {
                //                    extraSpaceForScroll = 0
                //                }
                //                cell.constraintScrollWidth.constant = extraSpaceForScroll
                
                return cell
            }
            else if indexPath.section == 1{
                //work life balance
                let cell = tableView.dequeueReusableCell(withIdentifier: "WorkCell", for: indexPath) as! WorkCell
                cell.selectionStyle = .none
                cell.btnmultiLineChart.addTarget(self, action: #selector(workLifeBalance), for: .touchUpInside)
                cell.lblWork.text = strWork + " hrs"
                cell.lblRelax.text = strRelaxation + " hrs"
                cell.lblSleep.text = strSleep + " hrs"
                cell.lblStress.text = strStress_level + " hrs"
                
                
                cell.sliderWork.value = (Float(strWork) ?? 0 )//24.0
                cell.sliderStress.value = (Float(strStress_level) ?? 0)//24.0
                cell.sliderRelax.value = (Float(strRelaxation) ?? 0)  //24.0
                cell.sliderSleep.value = (Float(strSleep) ?? 0)//24.0
                
                let work = Int(strWork)
                let relax = Int(strRelaxation)
                cell.setBalancingImage(work: work ?? 0, relax: relax ?? 0)
                cell.sliderWork.addTarget(self, action: #selector(self.sliderWorkAction(_:)), for: UIControlEvents.valueChanged)
                cell.sliderRelax.addTarget(self, action: #selector(self.sliderRelaxAction(_:)), for: UIControlEvents.valueChanged)
                cell.sliderSleep.addTarget(self, action: #selector(self.sliderSleepAction(_:)), for: UIControlEvents.valueChanged)
                cell.sliderStress.addTarget(self, action: #selector(self.sliderStressLevelAction(_:)), for: UIControlEvents.valueChanged)
                cell.btnSave.addTarget(self, action: #selector(SaveWorkLifeBalance), for: .touchUpInside)
                //                cell.selectionStyle = .none
                //                cell.btnmultiLineChart.addTarget(self, action: #selector(workLifeBalance), for: .touchUpInside)
                //                cell.lblWork.text = strWork + " hrs"
                //                cell.lblRelax.text = strRelaxation + " hrs"
                //                cell.lblSleep.text = strSleep + " hrs"
                //                cell.lblStress.text = strStress_level + " hrs"
                //
                //                cell.sliderWork.value = (Float(strWork) ?? 0 )/24.0
                //                cell.sliderStress.value = (Float(strStress_level) ?? 0)/24.0
                //                cell.sliderRelax.value = (Float(strRelaxation) ?? 0)/24.0
                //                cell.sliderSleep.value = (Float(strSleep) ?? 0) / 24.0
                //
                //                let work = Int(strWork)
                //                let relax = Int(strRelaxation)
                //                cell.setBalancingImage(work: work ?? 0, relax: relax ?? 0)
                //                cell.sliderWork.addTarget(self, action: #selector(self.sliderWorkAction(_:)), for: UIControlEvents.valueChanged)
                //                cell.sliderRelax.addTarget(self, action: #selector(self.sliderRelaxAction(_:)), for: UIControlEvents.valueChanged)
                //                cell.sliderSleep.addTarget(self, action: #selector(self.sliderSleepAction(_:)), for: UIControlEvents.valueChanged)
                //                cell.sliderStress.addTarget(self, action: #selector(self.sliderStressLevelAction(_:)), for: UIControlEvents.valueChanged)
                //                cell.btnSave.addTarget(self, action: #selector(SaveWorkLifeBalance), for: .touchUpInside)
                return cell
            }
            else {
                //Add Meeting
                let cell = tableView.dequeueReusableCell(withIdentifier: "projectRateCell", for: indexPath) as! projectRateCell
                cell.selectionStyle = .none
                let arrProject = self.arrProjectList[indexPath.row]
                cell.lblProjectName.text = arrProject.project_name
                cell.lblNegative.text = "\(arrProject.meeting_point_neg!)"
                cell.lblPositive.text = "\(arrProject.meeting_point_pos!)"
                let addMeetingValue = Int(arrProject.meeting_point!)
                cell.setBalancingImage(value: addMeetingValue ?? 0)
                cell.btnPlusProjectRate.addTarget(self, action: #selector(plusProjectRate), for: .touchUpInside)
                cell.btnMinusProjectRate.addTarget(self, action: #selector(minusProjectRate), for: .touchUpInside)
                
                cell.btnTimeLineBalanceChart.addTarget(self, action: #selector(TimeLineChartProject), for: .touchUpInside)
                return cell
            }
        }
            //Pop up View
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "popupCell", for: indexPath) as! LearningTableViewCell
            
            let dictValue = arrPopUpData[indexPath.row]
            let str = dictValue["data"] ?? ""
            cell.lblProjectPoints.text = str as? String
            
            if arrChoosedText.contains(str as! String)
            {
                cell.imgProject.image = UIImage(named:"check")
            }
            else
            {
                cell.imgProject.image = UIImage(named: "unCheck")
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == tblTracking{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tractingHeaderCell") as! tractingHeaderCell
            cell.lblHeader.numberOfLines = 0
            if section == 0{
                cell.lblHeader.text = "\(arrHeaderName[section]) as \(strPostingName) @ \(strCompanyName)"
            }
            else if section == 2 && self.arrProjectList.count>0{
                cell.lblHeader.text = "\(self.arrProjectList[0].project_name!) project"
            }
            else{
                cell.lblHeader.text = arrHeaderName[section]
            }
            return cell
        }else{
            let vw =  UIView()
            return vw
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblTracking{
            if indexPath.section == 0{
                print("Value Added Chart")
                let story = UIStoryboard(name: "TrackingStoryBoard", bundle: nil)
                let nextVC = story.instantiateViewController(withIdentifier: "ValueAddedChartVC") as! ValueAddedChartVC
                nextVC.projectID = projectID
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
            //Pop up View
        else{
            self.getSelectedText(selectedIndex: indexPath.row)
            tblPopup.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTracking{
            return 40
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblTracking{
            if indexPath.section == 0 {
                return  180
            } else if indexPath.section == 1  {
                return 340
            }
            else{
                return  212
            }
        }else{
            return 50
        }
    }
    
    //MARK:- Laddar Button
    func setLadderButton(cell:CareerCell) {
        
        for case let deleteView in cell.viewScrollContent.subviews {
            deleteView.removeFromSuperview()
        }
        var x = 20
        var y = 30 + (25 * (arrayCareerLevel.count - 1 ))
        for i in 0..<arrayCareerLevel.count {
            let button1 = UIButton(frame: CGRect(x: x, y: y, width: 77, height: 30))
            button1.setTitle(arrayCareerLevel[i].capitalized, for: .normal)
            button1.backgroundColor = UIColor.white
            button1.titleLabel?.textColor = UIColor.red
            button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button1.setTitleColor(UIColor.darkGray, for:.normal)
            //button1.setTitleColor(UIColor.black, for:.selected)
            button1.contentHorizontalAlignment = .left
            button1.contentVerticalAlignment = .top
            button1.titleLabel?.numberOfLines = 2
            button1.titleLabel?.lineBreakMode  = .byWordWrapping
            button1.tag = i
            
            let extraView = UIView(frame: CGRect(x: x-3, y: y-3, width: 80, height: 28))
            
            //Current Position
            if strPostingName == arrayCareerLevel[i]{
                extraView.backgroundColor = Constants.getCustomBlueColor()
            }
            else{
                extraView.backgroundColor = UIColor.darkGray
            }
            extraView.tag = i
            //        button1.addTarget(self, action: #selector(selectedButton), for: .touchUpInside)
            cell.viewScrollContent.addSubview(extraView)
            cell.viewScrollContent.addSubview(button1)
            cell.viewScrollContent.bringSubview(toFront: button1)
            x += 77
            y = y - 25
        }
        
    }
    
    //MARK:- Save Value Added Api
    func getValueAddedJSON() -> [String:Any]{
        return ["value_added" : valueRate,
                "project_id" : projectID,
                "user_id" : userId]
    }
    //MARK:- Save Value Added Api
    func getValueAddedFBJSON() -> [String:Any]{
        
        return ["value_added" : "\(self.valueRate)",
            "date_added" : self.getCurrentDate(),
            "user_id" : userId]
    }
    //MARK: - Add Value Added
    func valueAddedAPI(){
        WebserviceManager.shared.addVAlueAdded(view: self.view, dictBody: getValueAddedJSON(), Success: { (modelObj) in
            DispatchQueue.main.async {
                if modelObj.status == "success"{
                    
                    Utilities.displayFailureAlertWithMessage(title: "success", message: modelObj.message!, controller: self)
                }
                else{
                    Utilities.displayFailureAlertWithMessage(title: "Attention!", message: modelObj.message!, controller: self)
                }
            }
        }, Failure: { (error : String) in
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: error, controller: self)
        })
    }
    
    func getCurrentDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func valueAddedSaveApiFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("value_added").whereField("user_id", isEqualTo: userId).whereField("date_added", isEqualTo: self.getCurrentDate())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update value
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("value_added").document(documentID)
                refExist.updateData(self.getValueAddedFBJSON(), completion: { (error) in
                    print("value added update error: \(String(describing: error?.localizedDescription))")
                })
            }
            else
            {
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("value_added").addDocument(data: self.getValueAddedFBJSON(), completion: { (err) in
                    print("value added  insert error: \(String(describing: err?.localizedDescription))")
                })
            }
        }
        
        // update value added
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        ref2.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("tracking").document(documentID)
                refExist.updateData(["value_added" :(self.valueRate)])
                
            }
        }
    }
    
    
    //MARK:- Add Work Life Balance
    func getWorkLifeBalanceJSON() -> [String:Any]{
        return ["work" : strWork,
                "project_id" : projectID,
                "stress_level" : strStress_level,
                "relaxation" : strRelaxation,
                "sleep" : strSleep,
                "user_id" : userId]
    }
    
    func getWorkLifeBalanceFBJSON() -> [String:Any]{
        return ["work" : strWork,
                "stress_level" : strStress_level,
                "relaxation" : strRelaxation,
                "sleep" : strSleep,
                "date" : self.getCurrentDate(),
                "user_id" : userId]
    }
    
    func addWorkLifeBalanceAPI(){
        WebserviceManager.shared.addWorkLifeBalance(view: self.view, dictBody: getWorkLifeBalanceJSON(), Success: { (modelObj) in
            DispatchQueue.main.async {
                if modelObj.status == "success"{
                    
                    Utilities.displayFailureAlertWithMessage(title: "success", message: modelObj.message!, controller: self)
                }
                else{
                    Utilities.displayFailureAlertWithMessage(title: "Attention!", message: modelObj.message!, controller: self)
                }
            }
        }, Failure: { (error : String) in
            Utilities.displayFailureAlertWithMessage(title: "Attention!", message: error, controller: self)
        })
    }
    
    func addWorkLifeBalanceFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("work_life_bal").whereField("user_id", isEqualTo: userId).whereField("date", isEqualTo: self.getCurrentDate())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update value
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("work_life_bal").document(documentID)
                refExist.updateData(self.getWorkLifeBalanceFBJSON(), completion: { (error) in
                    print("work life balance error: \(String(describing: error?.localizedDescription))")
                })
            }
            else
            {
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("work_life_bal").addDocument(data: self.getWorkLifeBalanceFBJSON(), completion: { (err) in
                    print("work life balance error: \(String(describing: err?.localizedDescription))")
                })
            }
        }
        
        // update value added
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        ref2.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("tracking").document(documentID)
                refExist.updateData(["stress_level" :"\(self.strStress_level)"])
                refExist.updateData(["sleep" :"\(self.strSleep)"])
                refExist.updateData(["relaxation" :"\(self.strRelaxation)"])
                refExist.updateData(["work" :"\(self.strWork)"])
                
            }
        }
    }
    
    //MARK:- Add Meeting API
    func getAddMeetingJSON() -> [String:Any]{
        return ["type" : type,
                "project_id" : projectID,
                "user_id" : userId,
                "set":arrChoosedText,
                "point": strTotalPoints]
    }
    
    //for firebase
    func getAddMeetingFB_JSON() -> [String:Any]{
        print([
            "project_id" : strProjectIDForMeeting,
            "user_id" : userId,
            type:arrChoosedText,
            "point": strTotalPoints,
            "date": self.getCurrentDate()
            ])
        return [
            "project_id" : strProjectIDForMeeting,
            "user_id" : userId,
            type:arrChoosedText,
            "point": strTotalPoints,
            "date": self.getCurrentDate()
        ]
    }
    
    func projectListISLFirebase()
    {
        _ = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            
            if let snap = snapshot?.documents, snap.count > 0{
                self.parseIntoModel(snap: snap)
                self.reloadTableView()
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    
    func getCompanyDetail(){
        _ = FirebaseManager.shared.firebaseDP!.collection("companies_user").whereField("user_id", isEqualTo: userId).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0{
                self.PostingID = snap[0].get("position_id") as? String ?? "0"
                self.strPostingName = snap[0].get("posting_name") as? String ?? ""
                self.strCompanyName = snap[0].get("company_name") as? String ?? "Select Company"
                self.reloadTableView()
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    func enableFirestoreNW(){
        print(a)

        if a >= 3{
            a = 0
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    func createCompanyintoFB()
    {
        if let path = Bundle.main.path(forResource: "firebaseStatic", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.jsonCompany = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                self.arrayCompanies  +=   self.jsonCompany as? [[String:AnyObject]] ?? []
                let refCompany2 = FirebaseManager.shared.firebaseDP!.collection("companies")
                refCompany2.addDocument(data: ["companies" : self.jsonCompany!], completion: { (error) in
                    print("the create company error:\(error.debugDescription)")
                })
            } catch {
                // handle error
            }
        }
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
            model.meeting_point_pos = obj["meeting_point_pos"] as? Int ?? 0
            model.meeting_point_neg = obj["meeting_point_neg"] as? Int ?? 0
            arrProjectList.append(model)
        }
    }
    
    func addMeetingAPIFirebase(){
        strTotalPointsRef = self.strTotalPoints
        let ref = FirebaseManager.shared.firebaseDP!.collection("add_meeting").whereField("user_id", isEqualTo: userId).whereField("project_id", isEqualTo: self.strProjectIDForMeeting).whereField("date", isEqualTo: self.getCurrentDate())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update value
                let documentID = snap[0].documentID
                
                // update chart data and point
                if self.type == "positive"{
                    self.arrChoosedText += snap[0].get("positive") as? Array ?? []
                    self.strTotalPoints = snap[0].get("point") as! Int + self.strTotalPoints
                }
                else{
                    self.arrChoosedText += snap[0].get("negative") as? Array ?? []
                    self.strTotalPoints = snap[0].get("point") as! Int + self.strTotalPoints
                }
                
                let refExist = FirebaseManager.shared.firebaseDP!.collection("add_meeting").document(documentID)
                refExist.updateData(self.getAddMeetingFB_JSON(), completion: { (error) in
                    print("add meeting api error: \(String(describing: error?.localizedDescription))")
                })
                self.updateMeetingPointValues()
                
            }
            else
            {
                self.updateMeetingPointValues()
                
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("add_meeting").addDocument(data: self.getAddMeetingFB_JSON(), completion: { (err) in
                    print("add meeting api error: \(String(describing: err?.localizedDescription))")
                })
            }
        }
    }
    
    func updateMeetingPointValues()
    {
        // update value added
        
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("project_id", isEqualTo: self.strProjectIDForMeeting).whereField("user_id", isEqualTo: userId)
        ref2.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("projects").document(documentID)
                if self.type == "positive"{
                    let pos =  snap[0].get("meeting_point_pos") as? Int ?? 0
                    let tot = pos + self.strTotalPointsRef
                    refExist.updateData(["meeting_point" :"\(self.strTotalPoints )","meeting_point_pos" :tot])
                    self.projectListISLFirebase()
                }
                else{
                    let neg = snap[0].get("meeting_point_neg") as? Int ?? 0
                    let tot = neg + self.strTotalPointsRef
                    refExist.updateData(["meeting_point" :"\(self.strTotalPoints )","meeting_point_neg" :tot])
                    self.projectListISLFirebase()
                }
            }
        }
    }
    
    //MARK:- Add Meeting API
    func getAddCareerJSON() -> [String:Any]{
        return ["type" : type,
                "project_id" : projectID,
                "user_id" : userId,
                "set":arrChoosedText,
                "point": strTotalPoints,
                "career":strCareerLevel
        ]
    }
    
    //for firebase
    func getAddCareerFB_JSON() -> [String:Any]{
        return [
            "user_id" : userId,
            type:arrChoosedText,
            "point": strTotalPoints,
            "career":strCareerLevel,
            "date": self.getCurrentDate()
        ]
    }
    //for firebase
    func getAddTracking_JSON() -> [String:Any]{
        return [
            "user_id" : userId
        ]
    }
    func getTrackingFB(){
        _ = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            
            if let snap = snapshot?.documents, snap.count > 0 {
                // nothing
                self.valueRate = snap[0].get("value_added") as? Int ?? 0
                self.strSleep        = snap[0].get("sleep") as? String ?? ""
                self.strRelaxation   = snap[0].get("relaxation") as? String ?? ""
                self.strWork         = snap[0].get("work") as? String ?? ""
                self.strStress_level = snap[0].get("stress_level") as? String ?? ""
                self.strCareervalue     = Int(snap[0].get("career_point") as? String ?? "0")!
                self.trackingFb = snap[0]
                self.strCareerPositive = snap[0].get("career_point_pos") as? Int ?? 0
                self.strCareerNegative = snap[0].get("career_point_neg") as? Int ?? 0
                self.reloadTableView()
            }
            else
            {
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("tracking").addDocument(data: self.getAddTracking_JSON(), completion: { (err) in
                    print("add career api error: \(String(describing: err?.localizedDescription))")
                })
            }
            self.a = self.a + 1
            self.enableFirestoreNW()
        })
    }
    
    func addCareerFirebase(){
        strTotalPointsRef = self.strTotalPoints
        let ref = FirebaseManager.shared.firebaseDP!.collection("project_career").whereField("user_id", isEqualTo: userId).whereField("date", isEqualTo: self.getCurrentDate())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                
                // update value
                let documentID = snap[0].documentID
                
                // update chart data and point
                if self.type == "positive"{
                    self.arrChoosedText += snap[0].get("positive") as? Array ?? []
                    self.strTotalPoints = snap[0].get("point") as! Int + self.strTotalPoints
                }
                else{
                    self.arrChoosedText += snap[0].get("negative") as? Array ?? []
                    self.strTotalPoints = snap[0].get("point") as! Int + self.strTotalPoints
                }
                
                let refExist = FirebaseManager.shared.firebaseDP!.collection("project_career").document(documentID)
                refExist.updateData(self.getAddCareerFB_JSON(), completion: { (error) in
                    print("add career api error: \(String(describing: error?.localizedDescription))")
                })
                self.updateCareerPointValues()
            }
            else
            {
                //insert value if new
                _ = FirebaseManager.shared.firebaseDP!.collection("project_career").addDocument(data: self.getAddCareerFB_JSON(), completion: { (err) in
                    print("add career api error: \(String(describing: err?.localizedDescription))")
                })
                self.updateCareerPointValues()
            }
        }
        
    }
    func updateCareerPointValues()
    {
        // update value added
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("tracking").whereField("user_id", isEqualTo: userId)
        ref2.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("tracking").document(documentID)
                if self.type == "positive"{
                    let posVal = snap[0].get("career_point_pos") as? Int ?? 0
                    self.strCareerPositive = posVal + self.strTotalPointsRef
                    self.tblTracking.reloadData()
                    refExist.updateData(["career_point" :"\(self.strTotalPoints )","career_point_pos" :(self.strCareerPositive )])
                }
                else{
                    let negValue =  snap[0].get("career_point_neg") as? Int ?? 0
                    self.strCareerNegative =  negValue + self.strTotalPointsRef
                    self.tblTracking.reloadData()
                    refExist.updateData(["career_point" :"\(self.strTotalPoints )","career_point_neg" :(self.strCareerNegative )])
                }
                
            }
        }
    }
    //MARK:-Multi Selection For Model Text
    func getSelectedText(selectedIndex : Int)
    {
        let selectedIndex = arrPopUpData[selectedIndex]
        let selectedText:String = selectedIndex["data"] as! String
        let selectedvalue       = selectedIndex["value"] ?? 0
        if arrChoosedText.count > 0{
            if arrChoosedText.contains(selectedText){
                arrChoosedText = arrChoosedText.filter{ $0 != selectedText }
                //remove particular Value and Text
                strTotalPoints -= selectedvalue as! Int
            }else{
                arrChoosedText.append(selectedText)
                
                strTotalPoints += selectedvalue as! Int
                //Add particular Value and Text functionality
            }
        }
        else{
            arrChoosedText.append(selectedText)
            strTotalPoints += selectedvalue as! Int
        }
        print("Selected Text  ------------> ",arrChoosedText)
        print(strTotalPoints)
    }
    
    func reloadTableView(){
        self.tblTracking.reloadData()
    }
}

//MARK: - UITextFieldDelegate Methods
extension TrackingVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.location == 0 && string == " ") {
            return false;
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1{
            valueRate = Int(textField.text!) ?? 0
            tblTracking.reloadData()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension TrackingVC: CommentDelegates{
    func createCustomCommentInstance()
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        customCommentObj = mainStoryboard.instantiateViewController(withIdentifier: "CustomCommentVC") as! CustomCommentVC
        customCommentObj.delegate = self
    }
    
    //Add
    func addCustomComment() {
        self.view.addSubview(customCommentObj.view)
    }
    
    func removeCustomComment()
    {
        if customCommentObj != nil
        {
            customCommentObj.view.removeFromSuperview()
        }
    }
    
    func commentMe() {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = UserDefaults.standard.getUserID()
        nextVC.strFromVC = "Tracking"
        nextVC.strUserType = "Me"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func commentAnonymous() {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        nextVC.userID   = "0"
        nextVC.strFromVC = "Tracking"
        nextVC.strUserType = "Ananymous"
        self.navigationController?.pushViewController(nextVC, animated: true)
        removeCustomComment()
    }
    
    func canceled() {
        removeCustomComment()
    }
}



