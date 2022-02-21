//
//  AnimalCell.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/18/22.
//

import UIKit

class AnimalCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
