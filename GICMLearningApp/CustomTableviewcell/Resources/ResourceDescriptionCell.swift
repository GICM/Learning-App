//
//  ResourceDescriptionCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 18/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class ResourceDescriptionCell: UITableViewCell {
    @IBOutlet weak var lblsubSubtitle: UILabel!
    
    @IBOutlet weak var txtvwDescription: UITextView!
    @IBOutlet weak var imgRightSideBottom: UIImageView!
    @IBOutlet weak var imgRightSideTop: UIImageView!
    
    @IBOutlet weak var constraintTopSubtitle: NSLayoutConstraint!
    @IBOutlet weak var imgLeftSide: UIImageView!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var textViewWidthContraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
