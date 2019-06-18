//
//  LearningTableViewCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 25/05/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit
import SDWebImage

enum WhichSide {
    case Left
    case right
}

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
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightConstranit: NSLayoutConstraint!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var infoView: UIView!
    
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
    
    
    
    func setUpRightORLeft(side:WhichSide)
    {
        if side == .Left {
            if rightConstranit != nil {
                if leftConstraint != nil{
                    leftConstraint.constant = 5.0
                    rightConstranit.isActive = false
                }
            }
        }
        else if side == .right {
            if leftConstraint != nil{
                if rightConstranit != nil {
                    rightConstranit.constant = 5.0
                    leftConstraint.isActive = false
                }
            }
        }
    }
    
    func hideInfoView(){
        infoView.isHidden = true
    }
    
    
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        flipCard()
    }
    
    func flipCard() {
        if infoView.isHidden {
            UIView.transition( with: self.contentView, duration: 0.5, options: UIViewAnimationOptions(rawValue: UIViewAnimationOptions.transitionFlipFromRight.rawValue | UIViewAnimationOptions.showHideTransitionViews.rawValue), animations: {
                // self.contentView.addSubview(self.infoView)
                self.infoView.isHidden = false
            }, completion:  { finished in
                //HERE you can remove your old view
                //  self.mainView.removeFromSuperview()
                let image = UIImage(named: "close")
                self.infoButton.setImage(image, for: .normal)
                self.mainView.isHidden = true
            })
        }
        else {
            UIView.transition( with: self.contentView, duration: 0.5, options: UIViewAnimationOptions(rawValue: UIViewAnimationOptions.transitionFlipFromRight.rawValue | UIViewAnimationOptions.showHideTransitionViews.rawValue), animations: {
                // self.contentView.addSubview(self.infoView)
                self.mainView.isHidden = false
            }, completion:  { finished in
                //HERE you can remove your old view
                //  self.mainView.removeFromSuperview()
                let image = UIImage(named: "info")
                self.infoButton.setImage(image, for: .normal)
                self.infoView.isHidden = true
            })
        }
    }
    
}
