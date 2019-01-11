//
//  CareerLevelCell.swift
//  GICM
//
//  Created by Rafi on 06/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CareerLevelCell: UITableViewCell {

    @IBOutlet weak var btnCompanyName: UIButton!
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var careerLadderLevel: UILabel!
    @IBOutlet weak var careerLadderLVal: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setWidth(arrayCareerLevel: [String] , frameView: UIView){
        let totalLaddarButtonWidth = CGFloat((arrayCareerLevel.count*77) + 30)
        let screenWidth = frameView.frame.width
        var extraSpaceForScroll:CGFloat = 0
        if totalLaddarButtonWidth > screenWidth {
            extraSpaceForScroll = totalLaddarButtonWidth - screenWidth
        } else {
            extraSpaceForScroll = 0
        }
        widthConstraint.constant = extraSpaceForScroll
    }
    
    func careerLevel(strComapny: String){
        
        if strComapny == "Select Company"{
            vwContent.isHidden = true
            careerLadderLevel.isHidden = true
        }else{
            vwContent.isHidden = false
            careerLadderLevel.isHidden = false
        }
    }
    
}
