//
//  WeatherWithoutStatusCell.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/16/22.
//

import UIKit

class WeatherWithoutStatusCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
