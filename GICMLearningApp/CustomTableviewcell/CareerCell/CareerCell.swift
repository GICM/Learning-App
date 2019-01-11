//
//  CareerCell.swift
//  GICM
//
//  Created by Rafi on 28/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CareerCell: UITableViewCell {
    
    //MARK:- Initialization
    @IBOutlet weak var btnCareerPlus: UIButton!
    @IBOutlet weak var btnCareerMinus: UIButton!
    @IBOutlet weak var btnCareer: UIButton!
    @IBOutlet weak var imgCareer: UIImageView!
    @IBOutlet weak var lblNegative: UILabel!
    @IBOutlet weak var lblPositive: UILabel!

    @IBOutlet weak var lblCarrerLevel: UILabel!
    @IBOutlet weak var constraintScrollWidth: NSLayoutConstraint!
    @IBOutlet weak var viewScrollContent: UIView!
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    //MARK:- Local Methods
    //    func setBalancingImage(value : Int){
    //        if value == 0{
    //            imgCareer.image = UIImage(named: "wightScaleEqual")
    //        }else if value < 0{
    //            imgCareer.image = UIImage(named: "wightScaleRight")
    //        }else{
    //            imgCareer.image = UIImage(named: "wightScaleLeft")
    //        }
    //    }
    
    func setBalancingImage(value : Int){
        if value == 0{
            imgCareer.image = UIImage(named: "equal")
        }else if value < 0{
            if value < -200{
                imgCareer.image = UIImage(named: "right4")
            }
            else if value < -100{
                imgCareer.image = UIImage(named: "right3")
            }else if value < -50{
                imgCareer.image = UIImage(named: "right2")
            }else {
                imgCareer.image = UIImage(named: "right1")
            }
        }else{
            if value > 200{
                imgCareer.image = UIImage(named: "left4")
            }
            else if value >= 100{
                imgCareer.image = UIImage(named: "left3")
            }else if value >= 50{
                imgCareer.image = UIImage(named: "left2")
            }else {
                imgCareer.image = UIImage(named: "left1")
            }
        }
    }
    
}
