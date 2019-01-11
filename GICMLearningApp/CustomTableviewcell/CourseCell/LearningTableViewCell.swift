//
//  LearningTableViewCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 25/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage

class LearningTableViewCell: UITableViewCell {
  
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var labelCourseTitle: UILabel!
  @IBOutlet weak var labelShortDesc: UILabel!
  @IBOutlet weak var labelDescription: UILabel!
  @IBOutlet weak var imgCourseImage: UIImageView!
  @IBOutlet weak var imgBought: UIImageView!
    
    //Comment Cell
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var lblCommenterName: UILabel!
    
    //Pop up Cell
    @IBOutlet weak var lblProjectPoints: UILabel!
    @IBOutlet weak var imgProject: UIImageView!
    
    //Release Notes
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblReleaseNotes: UILabel!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
    
    func setupInviteFriends(model:PhoneContactModel) {
        lblCommenterName.text = model.name
        if model.avatarData != Data() {
            btnProfile.imageView?.image = UIImage(data: model.avatarData)
        } else {
            btnProfile.imageView?.image = #imageLiteral(resourceName: "userProfile")
        }
        
    }
  
}
