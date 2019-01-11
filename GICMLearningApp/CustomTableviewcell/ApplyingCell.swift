//
//  ApplyingCell.swift
//  GICM
//
//  Created by Rafi on 26/06/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SwipeCellKit

class ApplyingCell: SwipeTableViewCell {

    
    //MARK:- Initialization
    @IBOutlet weak var imgApplying: UIImageView!
    @IBOutlet weak var lblProjectName: UILabel!
    @IBOutlet weak var lblProjectStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
