//
//  MyExpandableTableViewSectionHeader.swift
//  LUExpandableTableViewExample
//
//  Created by Laurentiu Ungur on 24/11/2016.
//  Copyright © 2016 Laurentiu Ungur. All rights reserved.
//

import UIKit
import LUExpandableTableView

final class AdminHeaderTitleSectionHeader: LUExpandableTableViewSectionHeader {
    // MARK: - Properties
    
    
    @IBOutlet weak var switchHeader: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    
    override var isExpanded: Bool {
        didSet {
              switchHeader.setOn(isExpanded, animated: true)
        }
    
    }
    
    // MARK: - Base Class Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchHeader.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
    }
    
    func initialSetup(header:AdminHeaderTitleSectionHeader,index:Int) {
        delegate?.expandableSectionHeader(header, shouldExpandOrCollapseAtSection: index)
    }
    // MARK: - IBActions
   
    @IBAction func expandCollapseSwitch(_ sender: UISwitch) {
        
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
}
