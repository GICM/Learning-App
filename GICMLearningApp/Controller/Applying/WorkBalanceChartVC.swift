//
//  WorkBalanceChartVC.swift
//  GICMLearningApp
//
//  Created by CIPL on 30/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import  Charts
import FirebaseFirestore

class WorkBalanceChartVC: UIViewController {

    
    @IBOutlet weak var lineChartView: LineChartView!
    var arrWorkLifeBalance : [WorkLifeBalanceFB] = []
    var projectID = ""
    
    //Array
    var arrDates: [Double] = []
    var arrStress     : [Double] = []
    var arrWork       : [Double] = []
    var arrRelaxation : [Double] = []
    var arrSleep      : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

     //   valueAddedListAPI()
        getWorkLifeBalanceFB()
      //  setChart(lineChartView, dataPoints: monthLine, values1: dollars1, values2: dollars2, values3: dollars3, values4: dollars4)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- List Of Work Life Api
    func parseIntoModel(snap:[QueryDocumentSnapshot]){
        arrWorkLifeBalance.removeAll()
        for obj in snap{
            let model = WorkLifeBalanceFB()
            model.relaxation = obj["relaxation"] as? String ?? "0"
            model.sleep = obj["sleep"] as? String ?? "0"
            model.stress_level = obj["stress_level"] as? String ?? "0"
            model.work = obj["work"] as? String ?? ""
            model.user_id = obj["user_id"] as? String ?? ""
            model.date = obj["date"] as? String ?? ""
            arrWorkLifeBalance.append(model)
        }
    }
    
    func getWorkLifeBalanceFB(){
        let ref = FirebaseManager.shared.firebaseDP!.collection("work_life_bal").whereField("user_id", isEqualTo: UserDefaults.standard.getUserUUID())
        
        ref.getDocuments { (snapshot, error) in
            if let snap = snapshot?.documents, snap.count > 0 {
                self.parseIntoModel(snap: snap)
               self.fetchChartData()
            }
            print("get work life balance error: \(String(describing: error?.localizedDescription))")
        }
    }
    //Fetch work life Balance
    func fetchChartData(){
        
        arrWork = arrWorkLifeBalance.map({
            Double($0.work ?? "") ?? 0.0
        })
        arrSleep = arrWorkLifeBalance.map({
            Double($0.sleep ?? "") ?? 0.0
        })
        arrStress = arrWorkLifeBalance.map({
            Double($0.stress_level ?? "") ?? 0.0
        })
        arrRelaxation = arrWorkLifeBalance.map({
            Double($0.relaxation ?? "") ?? 0.0
        })
        arrDates = arrWorkLifeBalance.map({
            self.convert_decimal(dateString: $0.date ?? "")
        })
        let xvaluesString = arrWorkLifeBalance.map({
             $0.date ?? ""
        })
        print(arrWork,arrDates)
        WorkLifeBalanceLineChartModel.plotLineChart(lineChartView, xvaluesDouble: arrDates, xvaluesString: xvaluesString, sleepValues: arrSleep, relaxValues: arrRelaxation, stressValues: arrStress, workValues: arrWork)
    }
}


