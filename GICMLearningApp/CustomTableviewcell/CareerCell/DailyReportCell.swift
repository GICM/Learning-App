//
//  DailyReportCell.swift
//  GICMLearningApp
//
//  Created by CIPL0449 on 22/02/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit

class DailyReportCell: UITableViewCell {

    //MARK:- Initialiazation
    @IBOutlet weak var imgYes: UIImageView!
    @IBOutlet weak var imgNo: UIImageView!
    
     @IBOutlet weak var btnYes: UIButton!
     @IBOutlet weak var btnNo: UIButton!
     @IBOutlet weak var twComments: UITextView!
    
    @IBOutlet weak var twCommentHeight: NSLayoutConstraint!
    
    //MARK- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- ConfigUI
    func configUI(typeValue: String,strGoal: String){
        twCommentHeight.constant = 0.0
        clearAllSelection()
        let tagValue = typeValue
        switch tagValue{
        case "Yes":
            imgYes.image = #imageLiteral(resourceName: "radio-btn-check")
            twComments.isHidden = true
        case "No":
            twCommentHeight.constant = 60.0
            imgNo.image = #imageLiteral(resourceName: "radio-btn-check")
            twComments.isHidden = false
        default:
            print("Default")
        }
        twComments.text = "\(strGoal)"
    }
    
    //Clear All data
    func clearAllSelection(){
        imgYes.image = #imageLiteral(resourceName: "radio-btn-uncheck")
        imgNo.image = #imageLiteral(resourceName: "radio-btn-uncheck")
    }
    
}
