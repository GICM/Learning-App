//
//  ValueAddedChartVC.swift
//  GICMLearningApp
//
//  Created by Rafi on 29/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Charts
import FirebaseFirestore
import Instabug
class ValueAddedChartVC: UIViewController {
    
    @IBOutlet weak var vwBarChart: BarChartView!
    
    var projectID = ""
    var ProjectName = ""
    
    var xAxisValue: [String] = []
    var yAxisValue: [Double] = []
    var arrValueAdded : [ValueListFB] = []
    var arrValueAddedUpdated : [ValueListFB] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // valueAddedListAPI()
        valueAddedListFirebase()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDateFromString(strDate:String)->Date{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: strDate)!
    }
    func getStringFromDate(date:Date)->String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from:date)
    }
    
    func setChart(){
        
        // sorting array older to latest
        self.arrValueAdded = self.arrValueAdded.sorted(by: { (list1, list2) -> Bool in
            let date1 = self.getDateFromString(strDate: list1.date_added!)
            let date2 = self.getDateFromString(strDate: list2.date_added!)
            return date1 < date2
        })
        
        //get first date
        var date = self.getDateFromString(strDate: (self.arrValueAdded.first?.date_added)!)
        
        let endDate = Date()
        
        var strValue = "0"
        let userId = UserDefaults.standard.getUserID()
        
        // filling the values in between dates
        while date <= endDate {
            print(self.getStringFromDate(date: date))
            let strD = self.getStringFromDate(date: date)
            let model = ValueListFB()
            model.date_added = strD
            model.user_id = userId
            model.value_added = strValue
            
            if let value = self.arrValueAdded.filter({$0.date_added ?? "" == strD}).first?.value_added {
                model.value_added = value
                strValue = value
            }
            self.arrValueAddedUpdated.append(model)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        
        xAxisValue = self.arrValueAddedUpdated.map({$0.date_added ?? ""})
        yAxisValue = self.arrValueAddedUpdated.map({
            Double($0.value_added ?? "") ?? 0.0
        })
        
        print("x axis:\(xAxisValue)")
        print("y axis:\(yAxisValue)")
        
        ValueAddedChartModel.plotVerticalBarChart(xAxisValue: xAxisValue, yAxisValue: yAxisValue, chart: vwBarChart)
    }
    
    @IBAction func comment(_ sender: Any) {
        BugReporting.invoke()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- List Of Value Added Api
    func valueAddedListFirebase(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("value_added").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.parseIntoModel(snap: snap)
                self.setChart()
            }
             print("value added update error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        self.arrValueAdded.removeAll()
        for obj in snap{
            let model = ValueListFB()
            model.date_added = obj["date_added"] as? String ?? "0"
            model.user_id = obj["user_id"] as? String ?? ""
            model.value_added = obj["value_added"] as? String ?? ""
            arrValueAdded.append(model)
        }
    }
}

