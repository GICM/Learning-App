//
//  MyGoalCell.swift
//  GICM
//
//  Created by Rafi on 23/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class MyGoalCell: UITableViewCell {

    //MARK:- Initialization
    //Image
    @IBOutlet weak var imgAccelerated: UIImageView!
    @IBOutlet weak var imgLessStress: UIImageView!
    @IBOutlet weak var imgContribute: UIImageView!
    @IBOutlet weak var imgPersonal: UIImageView!
    @IBOutlet weak var imgOthers: UIImageView!

//Button
    @IBOutlet weak var btnAccelerated: UIButton!
    @IBOutlet weak var btnLessStress: UIButton!
    @IBOutlet weak var btnContribute: UIButton!
    @IBOutlet weak var btnPersonal: UIButton!
    @IBOutlet weak var btnOthers: UIButton!
    
    @IBOutlet weak var twMyGoal: UITextView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var twHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func clearAllGoalType(){
        imgAccelerated.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        imgLessStress.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        imgContribute.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        imgPersonal.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        imgOthers.image = #imageLiteral(resourceName: "radio-btn-uncheck")
    }
    
    func changeUI(typeValue: Int,strGoal: String , timing : Int){
        
        //Change Goal Type
        clearAllGoalType()
        twHeight.constant = 0.0
        let tagValue = typeValue
        switch tagValue{
        case 0:
            print("0")
            imgAccelerated.image = #imageLiteral(resourceName: "radio-btn-check")
        case 1:
            print("1")
            imgLessStress.image = #imageLiteral(resourceName: "radio-btn-check")
        case 2:
            print("2")
           imgContribute.image = #imageLiteral(resourceName: "radio-btn-check")
        case 3:
            print("3")
            imgPersonal.image = #imageLiteral(resourceName: "radio-btn-check")
        case 4:
            print("4")
            twHeight.constant = 60.0
            imgOthers.image = #imageLiteral(resourceName: "radio-btn-check")
        default:
            clearAllGoalType()
        }
        
        //Change GOAl Text
        twMyGoal.text = strGoal
        
        //Change Timing Value
        slider.value = Float(timing)
        
        if timing > 1{
             lblTime.text = " \(timing) Months"
        }else{
             lblTime.text = " \(timing) Month"
        }
        
     //   lblTime.text = " \(timing) Months"
    }
    
}
