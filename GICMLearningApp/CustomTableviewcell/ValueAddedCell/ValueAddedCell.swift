//
//  ValueAddedCell.swift
//  GICM
//
//  Created by Rafi on 27/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class ValueAddedCell: UITableViewCell {

    //MARK:- Initialization
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var txtRate: UITextField!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var btnDown: UIButton!
    @IBOutlet weak var btnUp: UIButton!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnValueAdded: UIButton!
    
    //AMRK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
