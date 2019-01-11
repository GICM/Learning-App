//
//  ProjectListCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 27/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SwipeCellKit

class ProjectListCell: SwipeTableViewCell {

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
