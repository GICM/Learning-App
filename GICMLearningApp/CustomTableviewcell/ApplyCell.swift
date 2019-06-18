//
//  ApplyCell.swift
//  GICM
//
//  Created by CIPL on 10/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SwipeCellKit

class ApplyCell: SwipeTableViewCell {

    @IBOutlet weak var lblLeftType: UILabel!
    @IBOutlet weak var lblRightType: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configUI(strTitle: String, indexPath:IndexPath){
        DispatchQueue.main.async {
            if indexPath.row % 2 == 0{
                self.lblLeftType.text = strTitle
                self.lblRightType.isHidden = true
            }else{
                self.lblRightType.text = strTitle
                self.lblLeftType.isHidden = true
            }
        }
    }
    
    func changeUIBackGround(strAppVersion: String,strTitle: String){
        let appVersion = appVersions.init(rawValue: strAppVersion)
        switch appVersion {
        case .weeklyPlan?:
            WeeklyPlanner(strTitle: strTitle)
        case .meetingManager?:
            Meetingmanager(strTitle: strTitle)
        case .tracking?:
            Tracking(strTitle: strTitle)
        case .capture?:
            Capture(strTitle: strTitle)
        default:
            print("Default")
        }
    }
    
    //Meeting manger
    func Meetingmanager(strTitle: String){
        if strTitle == "Meeting Manager"{
            contentView.alpha = 1.0
        }else{
            contentView.alpha = 1.0
        }
    }
    
    //Weekly planner
    func WeeklyPlanner(strTitle: String){
        if strTitle == "Weekly planner"{
            contentView.alpha = 1.0
        }else{
            contentView.alpha = 1.0
        }
    }
    
    //Capture
    func Capture(strTitle: String){
        if strTitle == "Capture"{
            contentView.alpha = 1.0
        }else{
            contentView.alpha = 1.0
        }
    }
    
    //Tracking
    func Tracking(strTitle: String){
        if strTitle == "Tracking"{
            contentView.alpha = 1.0
        }else{
            contentView.alpha = 1.0
        }
    }
    
    //Calculate
    func calculateInBetweenHours(strDate: String) {
        var appUsedDate = Date()
        let strDate = strDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        appUsedDate = dateFormatter.date(from: strDate)!
        
        let noOfDays = appUsedDate.hoursBetweenDate(from: Date())
        self.lblStatus.text = "\(noOfDays)"
    }
}




