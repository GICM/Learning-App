//
//  HeaderCell.swift
//  ExpandCollapseTableView
//
//  Created by CIPL0449 on 30/01/19.
//  Copyright © 2019 KANNA. All rights reserved.
//

import UIKit
import ExpyTableView

class HeaderCell: UITableViewCell,ExpyTableViewHeaderCell{
    
    @IBOutlet weak var labelPhoneName: UILabel!
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        
        switch state {
        case .willExpand:
            print("WILL EXPAND")
            hideSeparator()
            arrowDown(animated: !cellReuse)
            
        case .willCollapse:
            print("WILL COLLAPSE")
            arrowRight(animated: !cellReuse)
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            showSeparator()
            print("DID COLLAPSE")
        }
    }
    
    private func arrowDown(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
            self.imageViewArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi / 2))
        }
}
    
    private func arrowRight(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
            self.imageViewArrow.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
}

