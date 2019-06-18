//
//  WeekPlannerListCell.swift
//  GICM
//
//  Created by CIPL0449 on 04/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class WeekPlannerListCell: UITableViewCell {

    @IBOutlet weak var txtGoal: UITextField!
    @IBOutlet weak var txtExcercise: UITextField!
    @IBOutlet weak var lblWorkHours: UILabel!
    @IBOutlet weak var lblMeTimeHours: UILabel!
    
    @IBOutlet weak var lblWorkPercentage: UILabel!
    @IBOutlet weak var lblMeTimePercentage: UILabel!
    
    @IBOutlet weak var lblSleepHours: UILabel!
    @IBOutlet weak var slider: RangeSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSliderValues(workHours: Int, sleepHours: Int){
        print("Work \(workHours)")
        print("Rest \(sleepHours)")
        let sleep = 24 - sleepHours
        slider.lowerValue = Double(workHours)
        slider.upperValue = Double(sleepHours)
        
        
        let metimeHours = (24 - (workHours+sleep))
        self.setMeTimeHours(meTime: metimeHours)
        lblSleepHours.text = "\(sleep) hrs"
        
        let work = Float(workHours)/24.0
        let rest = 24 - workHours
        let restPercentage = Float(rest)/24.0
        
        let workPercentage = work*100
        let restPer = restPercentage*100
        lblWorkPercentage.text = "\(Int(workPercentage)) %"
        lblMeTimePercentage.text = "\(Int(restPer)) %"
        
        
        if workHours > 1{
            lblWorkHours.text = "\(workHours) hrs"
        }else{
            lblWorkHours.text = "\(workHours) hr"
        }
        
    }
    
    
    func setMeTimeHours(meTime: Int){
        if meTime > 1{
            lblMeTimeHours.text = "\(meTime) hrs"
        }else{
            lblMeTimeHours.text = "\(meTime) hr"
        }
    }
//    func changeMeTimeValue(sliderValue: String){
//
//        let IntValue = Int(sliderValue) ?? 0
//        let meTime = 10 - IntValue
//        lblWork.text = "\(IntValue*10) %"
//        lblMeTime.text = "\(meTime*10) %"
//    }
    

}

