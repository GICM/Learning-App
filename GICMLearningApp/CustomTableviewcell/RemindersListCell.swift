//
//  RemindersListCell.swift
//  GICM
//
//  Created by Rafi on 09/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SwipeCellKit

class RemindersListCell: SwipeTableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var switchReminder: UISwitch!
    @IBOutlet weak var imgIcon: UIImageView!
    var strTypeLocation = true
    var strType = "0" {
        didSet {
            if strType == "0"{
                imgIcon.image = #imageLiteral(resourceName: "Clock_B")
            }
            else if strType == "1"{
                if strTypeLocation{
                    imgIcon.image = #imageLiteral(resourceName: "location_arrived")
                }
                else{
                    imgIcon.image = #imageLiteral(resourceName: "location_leave")
                }
            } else {
                imgIcon.image = #imageLiteral(resourceName: "car_B")
            }
        }
    }
    
    var arrayDaystate:[Bool] = [false,false,false,false,false,false,false] {
        didSet {
            let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : Constants.getCustomBlueColor()]
            
            let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.darkGray]
            
            let attributedString1 = NSMutableAttributedString(string:"M ", attributes:arrayDaystate[0] ? attrs1 : attrs2)
            let attributedString2 = NSMutableAttributedString(string:"T ", attributes:arrayDaystate[1] ? attrs1 : attrs2)
            let attributedString3 = NSMutableAttributedString(string:"W ", attributes:arrayDaystate[2] ? attrs1 : attrs2)
            let attributedString4 = NSMutableAttributedString(string:"T ", attributes:arrayDaystate[3] ? attrs1 : attrs2)
            let attributedString5 = NSMutableAttributedString(string:"F ", attributes:arrayDaystate[4] ? attrs1 : attrs2)
            let attributedString6 = NSMutableAttributedString(string:"S ", attributes:arrayDaystate[5] ? attrs1 : attrs2)
            let attributedString7 = NSMutableAttributedString(string:"S ", attributes:arrayDaystate[6] ? attrs1 : attrs2)
            
            attributedString6.append(attributedString7)
            attributedString5.append(attributedString6)
            attributedString4.append(attributedString5)
            attributedString3.append(attributedString4)
            attributedString2.append(attributedString3)
            attributedString1.append(attributedString2)
            self.lblDay.attributedText = attributedString1
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setupUI(reminder:ReminderModel) {
        arrayDaystate = reminder.repeatEveryState
        lblTitle.text = reminder.title
        strTypeLocation = reminder.isArriving
        strType = reminder.type
        if strType == "2"{
            lblDetail.text = ""
        }else{
            lblDetail.text = reminder.descr
        }
        switchReminder.setOn(reminder.isReminderOn, animated: true)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

