//
//  PiechartLegendCell.swift
//  GICM
//
//  Created by Rafi on 16/08/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class PiechartLegendCell: UITableViewCell {

    @IBOutlet weak var txtfdTitle: UITextField!
    @IBOutlet weak var viewLegendBox: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = .zero
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
