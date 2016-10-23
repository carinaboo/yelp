//
//  SelectCell.swift
//  Yelp
//
//  Created by Carina Boo on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SelectCellDelegate: class {
    @objc optional func selectCell(selectCell: SelectCell,
                                   didChangeValue value: Bool)
}

class SelectCell: UITableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    
    weak var delegate: SelectCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (self.isSelected == selected) {
            return
        }
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
        delegate?.selectCell?(selectCell: self, didChangeValue: selected)
    }
    
}
