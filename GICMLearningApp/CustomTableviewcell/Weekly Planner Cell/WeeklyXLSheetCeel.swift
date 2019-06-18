//
//  WeeklyXLSheetCeel.swift
//  GICMLearningApp
//
//  Created by CIPL0449 on 19/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit

class WeeklyXLSheetCeel: UITableViewCell {

    @IBOutlet weak var txtStreamName: UITextField!
    @IBOutlet weak var btnPicked: UIButton!
    @IBOutlet weak var txtTravel: UITextField!
    @IBOutlet weak var txtRelation: UITextField!
    
    @IBOutlet weak var vwMeeting: UIView!
    @IBOutlet weak var vwResearch: UIView!
    @IBOutlet weak var vwDeliver: UIView!
    
 //   @IBOutlet weak var vwWeeklyPlannerData: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setWeeklyPlannerData(arrMeeting : [String],arrResearch: [String],arrDeliver: [String]){
        var meetingvalue = 0
        var research     = 0
        var deliver      = 0
        
        //Meeting
        for view in self.vwMeeting.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                textField.text = arrMeeting[meetingvalue]
                meetingvalue += 1
            }
        }
        //Research
        for view in self.vwResearch.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                textField.text = arrResearch[research]
                research += 1
            }
        }
        //Deliver
        for view in self.vwDeliver.subviews {
            if let textField = view.viewWithTag(view.tag) as? UITextField {
                textField.text = arrDeliver[deliver]
                deliver += 1
            }
        }
    }
    
    
}
