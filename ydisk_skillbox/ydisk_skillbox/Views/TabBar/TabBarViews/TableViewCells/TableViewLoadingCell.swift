//
//  TableViewLoadingCell.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 29.09.2022.
//

import UIKit

class TableViewLoadingCell: UITableViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
