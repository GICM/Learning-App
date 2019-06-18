//
//  WeeklyPlannerViewModel.swift
//  GICMLearningApp
//
//  Created by CIPL0449 on 12/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import Foundation
import ExpyTableView
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import SwiftRangeSlider


extension WeeklyPlannerListVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 200{
            
            let pointInTable = textField.convert(textField.bounds.origin, to: self.tblWeeklyPlannerList)
            let textFieldIndexPath = self.tblWeeklyPlannerList.indexPathForRow(at: pointInTable)
            
            self.currentSec = textFieldIndexPath?.section ?? 0
            self.strProjectID = arrProjectList[self.currentSec].project_id ?? ""
            self.currentIndexpath = textFieldIndexPath!
            
            let excercise = ["0","1","2","3","4","5","6","7"]
            self.listOfCompany(listData: excercise)
            
            return false
        }else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tblWeeklyPlannerList)
        let textFieldIndexPath = self.tblWeeklyPlannerList.indexPathForRow(at: pointInTable)
        self.currentSec = textFieldIndexPath?.section ?? 0
        self.strProjectID = arrProjectList[self.currentSec].project_id ?? ""
        guard let currentIndex = textFieldIndexPath else {
            return
        }
        self.currentIndexpath = currentIndex
        
        
        print("EDIT ENDED")
        let tagvalue = textField.tag
        
        switch tagvalue {
        case 100,200:
            self.editCommonWorkStramData()
        case 0...17:
            self.updateMeetingPointValues()
        default:
            print("None")
        }
    }
}

extension WeeklyPlannerListVC {
    func editWorkCommonJSON() -> [String:Any]{
        let cell = self.tblWeeklyPlannerList.cellForRow(at: self.currentIndexpath) as! WeekPlannerListCell
        let goal = cell.txtGoal.text ?? ""
        let excercise = cell.txtExcercise.text ?? ""
       let meTime = Int(cell.slider.lowerValue) //cell.txtMeTime.text ?? ""
       let sleep = Int(cell.slider.upperValue)
        
        let strMeTime = String(meTime)
        let strSleep = String(sleep)
        
        //self.arrayListofComment[visibleIndexPaths[0].row].status = self.quoteStatus
        
        self.arrProjectList[self.currentIndexpath.section].goal      = goal
        self.arrProjectList[self.currentIndexpath.section].excercise = excercise
        self.arrProjectList[self.currentIndexpath.section].meTime    = strMeTime
        self.arrProjectList[self.currentIndexpath.section].sleep     = strSleep
        
        return [
            "goal" : goal,
            "excercise": excercise,
            "meTime" : strMeTime,
            "sleep" : strSleep]
    }
    
    func editCommonWorkStramData(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").document(self.strProjectID)
        ref.updateData(self.editWorkCommonJSON(), completion: { (error) in
            print("Edit project Detail Error: \(String(describing: error))")
            if error == nil{
                print("Updated Weekly Deatils Successfully")
                //self.projectListISLFirebase()
            }
            else
            {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Update failed try again later", controller: self)
            }
        })
    }
    
    func editWeeklyPlannerJSON() -> [String:Any]{
        
        let cellEdit = tblWeeklyPlannerList.cellForRow(at: self.currentIndexpath) as? WeeklyXLSheetCeel
        var packed = ""
        if cellEdit?.btnPicked.currentImage == #imageLiteral(resourceName: "check"){
            packed = "1"
            // cell?.btnPacked.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
        }else{
            packed = "0"
        }
        
        var arrMeeting = [String]()
        var arrDeliver = [String]()
        var arrResearch = [String]()
        
        for view in (cellEdit?.vwMeeting.subviews)! {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                //textField.text = arrMeeting[meetingvalue]
                //   meetingvalue += 1
                let meeting = textField.text ?? "'"
                arrMeeting.append(meeting)
            }
        }
        
        //Research
        for view in (cellEdit?.vwResearch.subviews)! {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                let research = textField.text ?? "'"
                arrResearch.append(research)
            }
        }
        //Deliver
        for view in (cellEdit?.vwDeliver.subviews)! {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                let deliver = textField.text ?? "'"
                arrDeliver.append(deliver)
            }
        }
        
        print(arrMeeting)
        print(arrDeliver)
        print(arrResearch)
        
        
        let relation = cellEdit?.txtRelation.text ?? ""
        let travel = cellEdit?.txtTravel.text ?? ""
        
        
        let index = (self.currentIndexpath.row) - 2
        let modelObj = arrProjectList[self.currentIndexpath.section]
        print(modelObj)
        var subModel = modelObj.data![index]
        print(subModel.id ?? "")
        print(subModel.userName ?? "")
        
        var stram = cellEdit?.txtStreamName.text ?? ""
        stram = stram.replacingOccurrences(of: "()", with: "")
        var streamName = stram.components(separatedBy: "(")
        var latestStreamName = streamName[0].replacingOccurrences(of: ")", with: "")
        
        latestStreamName = latestStreamName.trimmingCharacters(in: .whitespacesAndNewlines)
        print(latestStreamName)
        if streamName.count > 1{
            var userName = streamName[1].replacingOccurrences(of: ")", with: "")
            print("UserName \(userName)")
            subModel.userName = userName
        }
        
        //  Change the Local Array Data
        self.arrProjectList[self.currentIndexpath.section].data![index].WorkStreamName = latestStreamName
        self.arrProjectList[self.currentIndexpath.section].data![index].userName = subModel.userName
        self.arrProjectList[self.currentIndexpath.section].data![index].Meetings = arrMeeting
        self.arrProjectList[self.currentIndexpath.section].data![index].Research = arrResearch
        self.arrProjectList[self.currentIndexpath.section].data![index].Deliverable = arrDeliver
        self.arrProjectList[self.currentIndexpath.section].data![index].relation = relation
        self.arrProjectList[self.currentIndexpath.section].data![index].Travel = travel
        self.arrProjectList[self.currentIndexpath.section].data![index].packed = packed
        
        self.currentWorkStramData.removeAll()
        for val in modelObj.data!{
            var dict = [String: Any]()
            if subModel.id == val.id{
                dict = ["id": subModel.id ?? "",
                        "WorkStream" : latestStreamName,
                        "Meetings": arrMeeting,
                        "Research" : arrResearch,
                        "Deliverable" : arrDeliver,
                        "userName" : subModel.userName ?? "",
                        "relation": relation,
                        "isNotStatic" : subModel.isStatic ?? true,
                        "Travel" : travel,
                        "packed": packed]
            }else{
                dict = ["id": val.id ?? "",
                        "WorkStream" : val.WorkStreamName ?? "",
                        "Meetings": val.Meetings ?? [],
                        "Research" : val.Research ?? [],
                        "Deliverable" : val.Deliverable ?? [],
                        "relation": val.relation ?? "",
                        "userName" : val.userName ?? "",
                        "Travel" : val.Travel ?? "",
                        "isNotStatic" : val.isStatic ?? true,
                        "packed": val.packed ?? ""]
            }
            self.currentWorkStramData.append(dict)
        }
        
        print("Dict : \(self.currentWorkStramData)")
        return ["workStreamData" : self.currentWorkStramData]
    }
    
    func updateMeetingPointValues()
    {
        // update value added
        
        let ref2 = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("project_id", isEqualTo: self.strProjectID).whereField("user_id", isEqualTo: userId)
        ref2.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                let documentID = snap[0].documentID
                let refExist = FirebaseManager.shared.firebaseDP!.collection("projects").document(documentID)
                
                // refExist.child("yourKey").child("yourKey").updateChildValues(["yourKey": yourValue])
                refExist.updateData(self.editWeeklyPlannerJSON())
                
                // ref?.child("wins").updateChildValues("wins": numerator)
              //  self.projectListISLFirebase()
            }else{
                Utilities.sharedInstance.showToast(message: "\(String(describing: error))")
            }
        }
    }
    
}


//MARK:- CustomPicker Methods
extension WeeklyPlannerListVC :CustomPickerDelegate {
    
    
    func createCustomPickerInstance(){
        customPickerObj = Utilities.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func listOfCompany(listData : [String]){
        
        customPickerObj.totalComponents = 1
        customPickerObj.arrayComponent = listData
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_String)
        customPickerObj.customPicker.reloadAllComponents()
    }
    
    
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
        self.customPickerObj.vwBaseView.frame.size.height = self.view.frame.size.height
        self.customPickerObj.vwBaseView.frame.size.width = self.view.frame.size.width
    }
    
    func removeCustomPicker(){
        if customPickerObj != nil{
            customPickerObj.view.removeFromSuperview()
        }
    }
    
    func itemPicked(item: AnyObject) {
        let pickerDateValue = item as! String
        let excercise = pickerDateValue
        let cell = self.tblWeeklyPlannerList.cellForRow(at: self.currentIndexpath) as! WeekPlannerListCell
        cell.txtExcercise.text = excercise ?? ""
        self.textFieldDidEndEditing(cell.txtExcercise)
        
        removeCustomPicker()
    }
    
    func pickerCancelled(){
        removeCustomPicker()
        selectedPicker = ""
    }
}

extension WeeklyPlannerListVC{
    func projectListISLFirebase()
    {
        let ref = FirebaseManager.shared.firebaseDP!.collection("projects").whereField("user_id", isEqualTo: userId)
        ref.getDocuments(completion: { (snapshot, error) in
            if let snap = snapshot?.documents {
                if snap.count > 0
                {
                    self.parseIntoModel(snap: snap)
                    self.tblWeeklyPlannerList.reloadData()
                    self.tblWeeklyPlannerList.expand(0)
                }else{
                    self.callTimer()
                }
                self.a = self.a + 1
                self.enableFirestoreNW()
            }else{
                self.callTimer()
            }
            if error != nil{
                self.callTimer()
            }
        })
    }
    
    
    func callTimer(){
        self.vwTimerPopUp.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(WeeklyPlannerListVC.navigateToProfile)), userInfo: nil, repeats: true)
    }
    
    @objc func navigateToProfile(){
        currentTimeCount += 1
        let printValue = timerCount - currentTimeCount
        if printValue == 0{
            self.timer.invalidate()
            self.profileViewController()
        }else{
            self.lblTimer.text = "\(printValue)"
        }
    }
    
    @objc func hidepauseIcon(){
       btnPlayOption.isHidden = true
       self.timer.invalidate()
    }
    
    func profileViewController(){
        let vc = Utilities.sharedInstance.viewControllerWithName(identifier: Constants.StoryboardIdentifier.tabbar) as! TabBarViewController
        vc.selectedIndex = 4
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func enableFirestoreNW(){
        print(a)
        if a >= 4 {
            a = 0
            Firestore.firestore().enableNetwork(completion: nil)
        }
    }
    
    // Caluclate No of weeks
    func noOfWeeks(startDate: String) -> Int{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateStart = dateFormatter.date(from: startDate)//df.string(from: startDate)
        let appUsedDate = Date()
        let userLastUsed = dateStart!.daysBetweenDate(toDate: appUsedDate)
        var weeks:Float = Float(userLastUsed)/7.0
        weeks.round(.up)
        
        var positive = abs(Int(weeks))
        if positive > 0{
            
        }else{
            positive = 1
        }
        return positive
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
            model.workStreamData = obj["workStreamData"] as? [[String:Any]] ?? []
            
            model.goal = obj["goal"] as? String ?? ""
            model.excercise = obj["excercise"] as? String ?? ""
            model.meTime = obj["meTime"] as? String ?? ""
            model.sleep = obj["sleep"] as? String ?? ""
            
            var arrSub : [WeeklyPlannerData] = []
            for sub in obj["workStreamData"] as? [[String:Any]] ?? []{
                var submodel = WeeklyPlannerData()
                submodel.id = sub["id"]  as? String ?? ""
                submodel.WorkStreamName = sub["WorkStream"] as? String ?? ""
                submodel.Deliverable = sub["Deliverable"] as? [String] ?? []
                
                submodel.Meetings = sub["Meetings"] as? [String] ?? []
                submodel.Research = sub["Research"] as? [String] ?? []
                submodel.Travel   = sub["Travel"] as? String ?? ""
                submodel.userName = sub["userName"] as? String ?? ""
                submodel.isStatic = sub["isNotStatic"] as? Bool ?? false
                
                submodel.packed = sub["packed"] as? String ?? ""
                submodel.relation = sub["relation"] as? String ?? ""
                arrSub.append(submodel)
            }
            
            model.data = arrSub
            print(arrSub)
            
            arrProjectList.append(model)
        }
    }
    
    
    @objc func packed(sender: UIButton!) {
        
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblWeeklyPlannerList)
        let cellIndexPath = self.tblWeeklyPlannerList.indexPathForRow(at: pointInTable)
        let cell = tblWeeklyPlannerList.cellForRow(at: cellIndexPath!) as? WeeklyXLSheetCeel
        let index = (cellIndexPath?.row)! - 2
        let modelObj = arrProjectList[(cellIndexPath?.section)!]
        print(modelObj)
        let subModel = modelObj.data![index]
        print(subModel)
        
        if cell?.btnPicked.currentImage == #imageLiteral(resourceName: "check"){
            
            cell?.btnPicked.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
        }else{
            cell?.btnPicked.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }
        
        self.currentSec = cellIndexPath?.section ?? 0
        self.strProjectID = arrProjectList[self.currentSec].project_id ?? ""
        self.currentIndexpath = cellIndexPath!
       self.updateMeetingPointValues()
    }
}

extension WeeklyPlannerListVC: ExpyTableViewDataSource,ExpyTableViewDelegate {
    
//        @IBAction func sliderMeTime(_ sender: UISlider) {
//            print(sender.value)
//            let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblWeeklyPlannerList)
//            let cellIndexPath = self.tblWeeklyPlannerList.indexPathForRow(at: pointInTable)
//            let value = Int(sender.value)
//            let cell = tblWeeklyPlannerList.cellForRow(at: cellIndexPath!) as? WeekPlannerListCell
//            cell?.changeMeTimeValue(sliderValue: String(value))
//
//            self.currentSec = cellIndexPath?.section ?? 0
//            self.strProjectID = arrProjectList[self.currentSec].project_id ?? ""
//            self.currentIndexpath = cellIndexPath!
//        }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrProjectList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var arrLength = 1
        if (arrProjectList[section].data?.count)! > 0{
            arrLength = (arrProjectList[section].data?.count)! + 2
        }else{
            arrLength = 1
        }
        return arrLength
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyPlannerHeaderCell") as! WeeklyPlannerHeaderCell
        let modelObj = arrProjectList[section]
        let projectName = modelObj.project_name
        let startDate =  modelObj.start_date ?? ""
        let positive = self.noOfWeeks(startDate: startDate)
        cell.lblName.text =  "\(projectName ?? "") (week \(positive))"//arrheader[section].sectionName
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyXLSheetCeel", for: indexPath) as! WeeklyXLSheetCeel
            
            serdeleToEdit(cell: cell)
            cell.selectionStyle = .none

            let index = (indexPath.row) - 2
            let modelObj = arrProjectList[(indexPath.section)]
            print(modelObj)
            let subModel = modelObj.data![index]
            print(subModel)
            cell.setWeeklyPlannerData(arrMeeting: subModel.Meetings!, arrResearch: subModel.Research!, arrDeliver: subModel.Deliverable!)
            cell.txtStreamName.text = "\(subModel.WorkStreamName ?? "") (\(subModel.userName ?? "me"))"

            cell.txtRelation.text = "\(subModel.relation ?? "")"
            cell.txtTravel.text = "\(subModel.Travel ?? "")"

            if subModel.packed == "0"{
                cell.btnPicked.setImage(#imageLiteral(resourceName: "unCheck"), for: .normal)
            }else{
                cell.btnPicked.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
            cell.btnPicked.addTarget(self, action: #selector(packed), for: .touchUpInside)
            cell.showSeparator()
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekPlannerListCell", for: indexPath) as! WeekPlannerListCell
            setDelegate(cell: cell)
            
            let index = (indexPath.section)
            let modelObj = arrProjectList[index]
            
            cell.txtGoal.text = modelObj.goal ?? ""
            cell.txtExcercise.text = modelObj.excercise ?? ""
            
            let work = Int(modelObj.meTime!)
            let sleep = Int(modelObj.sleep ?? "7")
            cell.slider.isUserInteractionEnabled = true
            cell.setSliderValues(workHours: work ?? 8, sleepHours: sleep ?? 7)
            cell.slider.addTarget(self, action: #selector(self.myGoalSelection), for: .touchUpInside)
            
          //  cell.changeMeTimeValue(sliderValue: modelObj.meTime ?? "0")
          //   cell.sliderMeTime.addTarget(self, action: #selector(self.sliderMeTime(_:)), for: UIControlEvents.valueChanged)
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 50
        }else if indexPath.row == 1{
            return 185
        }else{
            return 340
        }
    }
    
    @objc func myGoalSelection(sender: RangeSlider){
       
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tblWeeklyPlannerList)
        let cellIndexPath = self.tblWeeklyPlannerList.indexPathForRow(at: pointInTable)
        let cell = tblWeeklyPlannerList.cellForRow(at: cellIndexPath!) as? WeekPlannerListCell
        
        var maxValue = Int(sender.upperValue)
        let minValue = Int(sender.lowerValue)
        
        if maxValue < 15{
          maxValue = 15
        }else if maxValue > 19{
          maxValue = 19
        }
        
        cell?.setSliderValues(workHours: minValue, sleepHours: maxValue)
        self.currentSec = cellIndexPath?.section ?? 0
        self.strProjectID = arrProjectList[self.currentSec].project_id ?? ""
        
        guard let currentIndex = cellIndexPath else {
            return
        }
        
        self.currentIndexpath = currentIndex

        
        self.editCommonWorkStramData()
    }
    
    func setDelegate(cell: WeekPlannerListCell){
        cell.txtGoal.delegate = self
        cell.txtGoal.tag = 100
        cell.txtExcercise.delegate = self
        cell.txtExcercise.tag = 200
    }
    
    
    func serdeleToEdit(cell: WeeklyXLSheetCeel){
        cell.txtStreamName.delegate = self
        cell.txtTravel.delegate = self
        cell.txtRelation.delegate = self
        
        for view in cell.vwMeeting.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                textField.delegate = self
            }
        }
        
        //Research
        for view in cell.vwResearch.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
            textField.delegate = self
            }
        }
        
        //Deliver
        for view in cell.vwDeliver.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                textField.delegate = self
            }
        }
    }


}
