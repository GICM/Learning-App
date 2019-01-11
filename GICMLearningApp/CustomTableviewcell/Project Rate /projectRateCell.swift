//
//  projectRateCell.swift
//  GICM
//
//  Created by Rafi on 27/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit



class projectRateCell: UITableViewCell {
    
    
    @IBOutlet weak var lblProjectName: UILabel!
    @IBOutlet weak var btnAddMeeting: UIButton!
    @IBOutlet weak var btnMinusProjectRate: UIButton!
    @IBOutlet weak var btnPlusProjectRate: UIButton!
    @IBOutlet weak var btnTimeLineBalanceChart: UIButton!
    @IBOutlet weak var imgAddMeeting: UIImageView!
    @IBOutlet weak var lblNegative: UILabel!
    @IBOutlet weak var lblPositive: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setBalancingImage(value : Int){
        if value == 0{
            imgAddMeeting.image = UIImage(named: "equal")
        }else if value < 0{
            if value < -200{
                imgAddMeeting.image = UIImage(named: "right4")
            }
            else if value < -100{
                imgAddMeeting.image = UIImage(named: "right3")
            }else if value < -50{
                imgAddMeeting.image = UIImage(named: "right2")
            }else {
                imgAddMeeting.image = UIImage(named: "right1")
            }
        }else{
            if value > 200{
                imgAddMeeting.image = UIImage(named: "left4")
            }
            else if value >= 100{
                imgAddMeeting.image = UIImage(named: "left3")
            }else if value >= 50{
                imgAddMeeting.image = UIImage(named: "left2")
            }else {
                imgAddMeeting.image = UIImage(named: "left1")
            }
        }
    }
    
}
