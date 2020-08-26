//
//  MusicCell.swift
//  BasicRxSwift
//
//  Created by Le Phuong Tien on 8/26/20.
//  Copyright © 2020 Fx Studio. All rights reserved.
//

import UIKit

class MusicCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
