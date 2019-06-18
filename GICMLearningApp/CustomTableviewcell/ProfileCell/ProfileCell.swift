//
//  ProfileCell.swift
//  GICM
//
//  Created by Rafi on 04/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
  
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var btnLogOut: UIButton!
    
    @IBOutlet weak var btFAQ: UIButton!
    @IBOutlet weak var btFeedback: UIButton!

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Delegate Method
    
    
    func setCellDetails(email: String, userName: String, dob: String , strImage:String){
        self.txtName.text = userName
        self.txtMail.text = email
        self.txtDOB.text = dob
        
        if let dataDecoded : Data = Data(base64Encoded: strImage){
            if let image = UIImage(data: dataDecoded)
            {
            imgProfile.image = image
            }
            else
            {
                imgProfile.image = UIImage(named: "Userprofile")
            }
        }
    }
}
