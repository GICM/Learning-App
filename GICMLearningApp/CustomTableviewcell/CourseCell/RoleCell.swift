//
//  RoleCell.swift
//  GICM
//
//  Created by Rafi on 20/11/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class RoleCell: UITableViewCell {

    @IBOutlet weak var lblCourse: UILabel!
    @IBOutlet weak var imgCourse: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
