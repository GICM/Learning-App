//
//  TimeLineChartCell.swift
//  GICM
//
//  Created by Rafi on 02/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class TimeLineChartCell: UITableViewCell {

    //MARK:- Initialization
    @IBOutlet weak var lblNegative: UILabel!
    @IBOutlet weak var lblPositive: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
