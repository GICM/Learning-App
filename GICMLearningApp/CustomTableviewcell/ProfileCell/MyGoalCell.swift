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
    // Compare Myself
    @IBOutlet weak var vwOwnHistory: UIView!
    @IBOutlet weak var vwFirmPeers: UIView!
    @IBOutlet weak var vwCountry: UIView!
    @IBOutlet weak var vwWorldWide: UIView!
    
    @IBOutlet weak var btnOwnHistory: UIButton!
    @IBOutlet weak var btnFirmPeers: UIButton!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnWorldWide: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
}
