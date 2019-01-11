//
//  QuotesCell.swift
//  GICMLearningApp
//
//  Created by Rafi on 17/07/18.
//  Copyright © 2018 Rafi. All rights reserved.
//

import UIKit

class QuotesCell: UICollectionViewCell {
    
    @IBOutlet weak var lblQuotes: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    func checkImage(like: String){
            if like == "1"{
                self.btnLike.setImage(#imageLiteral(resourceName: "Liked"), for: .normal)
            }else if like == "2"{
                self.btnLike.setImage(#imageLiteral(resourceName: "unLike"), for: .normal)
            }else{
                self.btnLike.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
            }
    }
    
    

}
