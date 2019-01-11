//
//  CallBackUpCell.swift
//  GICM
//
//  Created by Rafi on 19/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CallBackUpCell: UITableViewCell {

    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblName2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
