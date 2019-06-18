//
//  GoalDefinitionCell.swift
//  GICM
//
//  Created by CIPL0449 on 4/5/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit

class GoalDefinitionCell: UITableViewCell {

    @IBOutlet weak var vwGoal: UIView!
    @IBOutlet weak var lblGoal: UILabel!
    @IBOutlet weak var heightContraint: NSLayoutConstraint!

    @IBOutlet weak var vwGoalList: UIView!
    @IBOutlet weak var twGoal: UITextView!
    
 
    
    // Time Tiles
    @IBOutlet weak var vwOneYear: UIView!
    @IBOutlet weak var vwTwoYear: UIView!
    @IBOutlet weak var vwThreeYear: UIView!
    @IBOutlet weak var vwNoPressure: UIView!
    
    @IBOutlet weak var btnOneYear: UIButton!
    @IBOutlet weak var btnTwoYear: UIButton!
    @IBOutlet weak var btnThreeYear: UIButton!
    @IBOutlet weak var btnNoPressure: UIButton!
    
    

    
    @IBOutlet weak var heightOtherContraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var swGoal: UIStackView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupGoalDefination(strGoal: String){
        self.lblGoal.text = strGoal 
//        if arrGoal.count == 0{
//            self.lblGoal.text = "Select goals for consutants"
//        }else{
//        var strGoal = ""
//        for index in arrGoal{
//            strGoal.append("- \(index) \n")
//        }
//        print(strGoal)
//        self.lblGoal.text = strGoal
//        }
    }
    
    
    func myGoalTopSelectionView(arrGoal : [String] , duration: String, isSelected: Bool){
        if arrGoal.count == 0 {
            self.lblGoal.text = "Select your goal"
        }else{
            var strGoal = ""
            var count = 0
            for goal in arrGoal{
                if count == 0{
                    strGoal.append("\(goal)")
                }else{
                    strGoal.append(",  \(goal)")
                }
                count += 1
            }
            self.lblGoal.text = "\(strGoal) in \(duration)"
        }
        if isSelected{
            self.vwGoalList.isHidden = false
            self.vwGoal.isHidden = false
            self.swGoal.isHidden = false
            
        }else{
            self.vwGoalList.isHidden = true
             self.vwGoalList.isHidden = true
             self.swGoal.isHidden = true
        }
    }
}
