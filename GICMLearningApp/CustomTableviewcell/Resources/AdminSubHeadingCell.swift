//
//  AdminSubHeadingCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 20/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class AdminSubHeadingCell: UITableViewCell {
    @IBOutlet weak var imgReject: UIImageView!
    
    @IBOutlet weak var lblReject: UILabel!
    @IBOutlet weak var imgScreen: UIImageView!
    @IBOutlet weak var imgDate: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblScreen: UILabel!
    
    @IBOutlet weak var constraintCommentLbl: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgReject.image = UIImage()
        imgScreen.image = UIImage()
        imgDate.image = UIImage()
        imgUser.image = UIImage()
        imgDelete.image = UIImage()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
