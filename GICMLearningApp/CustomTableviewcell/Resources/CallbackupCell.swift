//
//  Call4backupCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 20/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class CallbackupCell: UITableViewCell {
    @IBOutlet weak var lblDelete: UILabel!
    
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var imgDate: UIImageView!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var lblRequestState: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
