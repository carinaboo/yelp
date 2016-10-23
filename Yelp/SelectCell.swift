//
//  SelectCell.swift
//  Yelp
//
//  Created by Carina Boo on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

//@objc protocol SelectCellDelegate: class {
//    @objc optional func selectCell(selectCell: SelectCell,
//                                   didChangeValue value: Bool)
//}

class SelectCell: UITableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    
//    weak var delegate: SelectCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func selectedChanged() {
//        delegate?.selectCell?(selectCell: self, didChangeValue: selected)
    }
    
}
