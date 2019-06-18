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
    @IBOutlet weak var btnAddWorkStream: UIButton!
    
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeUI(arrWorkStream: [String], userName: [String]){
        
        print(arrWorkStream.count)
        for case let deleteView in self.vwContent.subviews {
            deleteView.removeFromSuperview()
        }
        
        let x = 30  //+ (25 * (arrString.count - 1))
        var y = 2
        
        for i in 0..<arrWorkStream.count{
            let label = UILabel(frame: CGRect(x: x, y: y, width: Int(UIScreen.main.bounds.width - 50), height: 30))
            label.text = "  - \(arrWorkStream[i]) (\(userName[i]))"
            label.numberOfLines = 2
            label.font = UIFont.boldSystemFont(ofSize: 14)
            self.vwContent.addSubview(label)
            y += 35
        }
        
        //        let heightView = CGFloat((arrWorkStream.count * 25)) // + 40)
        //        heightConstant.constant = heightView
        
        let totalLaddarButtonWidth = CGFloat((arrWorkStream.count*35) + 5)
        heightConstant.constant = totalLaddarButtonWidth
        
    }
    
}
