//
//  WorkLifeBalanceCell.swift
//  GICM
//
//  Created by Rafi on 29/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class WorkLifeBalanceCell: UITableViewCell {
    
    //MARK:- Horizotal
    @IBOutlet weak var lblStress: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblSleep: UILabel!
    @IBOutlet weak var lblRelax: UILabel!
    @IBOutlet weak var lblWork: UILabel!
    @IBOutlet weak var sliderWork: MJSlider!
    @IBOutlet weak var sliderStress: MJSlider!
    @IBOutlet weak var btnmultiLineChart: UIButton!
    @IBOutlet weak var sliderRelax: MJSlider!
    @IBOutlet weak var sliderSleep: MJSlider!
    @IBOutlet weak var imgWork: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sliderWork.layer.borderWidth = 2.0
        sliderStress.layer.borderWidth = 2.0
        sliderRelax.layer.borderWidth = 2.0
        sliderSleep.layer.borderWidth = 2.0
        
        let colorBlue = Constants.getCustomBlueColor()
        sliderWork.tintColor = colorBlue
        sliderStress.tintColor = colorBlue
        sliderRelax.tintColor = colorBlue
        sliderSleep.tintColor = colorBlue
        
        sliderWork.value = 0
        sliderStress.value = 0
        sliderRelax.value = 0
        sliderSleep.value = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- Local Methods
    func setBalancingImage(work : Int,relax: Int){
        if work == relax{
            imgWork.image = UIImage(named: "equal")
        }else if work > relax{
            let percentage = work - relax
            if percentage >= 12{
                imgWork.image = UIImage(named: "right4")
            }
            else if percentage >= 9{
                imgWork.image = UIImage(named: "right3")
            }else if percentage >= 6{
                imgWork.image = UIImage(named: "right2")
            }else {
                imgWork.image = UIImage(named: "right1")
            }
        }else{
            let percentage = relax - work
            if percentage >= 12{
                imgWork.image = UIImage(named: "left4")
            }
            else if percentage >= 9{
                imgWork.image = UIImage(named: "left3")
            }else if percentage >= 6{
                imgWork.image = UIImage(named: "left2")
            }else {
                imgWork.image = UIImage(named: "left1")
            }
        }
    }
}
