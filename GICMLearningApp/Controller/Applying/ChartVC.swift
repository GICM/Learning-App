//
//  ChartVC.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import Charts

class ChartVC: UIViewController {

    //MARK:- Initialiazation
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var fromVC = ""
    var arrDatesString           : [String] = []
    var arrDatesDouble           : [Double] = []
    var arrYaxisValues     : [Double] = []
    
    //MARK:- View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       print(arrDatesString)
       print(arrYaxisValues)
        if fromVC == "Career timeline"{
            lblTitle.text = "Career diagram"
        }else{
            lblTitle.text = "Project diagram"
        }
        
        ChartModel.plotSingleLineChart(lineChart, xAxisValuesString: arrDatesString, xAxisValuesDouble: arrDatesDouble, yAxisValue: arrYaxisValues, legendName: fromVC)
    }
    
    //MARK:- Button Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Local Methods


    //MARK:- Delegate Methods
    
    
}
