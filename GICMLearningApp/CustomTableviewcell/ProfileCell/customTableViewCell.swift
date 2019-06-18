//
//  customTableViewCell.swift
//  GICM
//
//  Created by CIPL0449 on 4/5/19.
//  Copyright © 2019 Praveenkumar R. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell {

    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var lblGoal: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
