//
//  WorkCell.swift
//  GICM
//
//  Created by Rafi on 11/12/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class WorkCell: UITableViewCell {

    //MARK:- Horizotal
    @IBOutlet weak var lblStress: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblSleep: UILabel!
    @IBOutlet weak var lblRelax: UILabel!
    @IBOutlet weak var lblWork: UILabel!
    @IBOutlet weak var sliderWork: UISlider!
    @IBOutlet weak var sliderStress: UISlider!
    @IBOutlet weak var btnmultiLineChart: UIButton!
    @IBOutlet weak var sliderRelax: UISlider!
    @IBOutlet weak var sliderSleep: UISlider!
    @IBOutlet weak var imgWork: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
