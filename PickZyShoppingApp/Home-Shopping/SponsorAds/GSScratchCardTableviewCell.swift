//
//  GSScratchCardTableviewCell.swift
//  Shopor
//
//  Created by Ratheesh on 28/12/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSScratchCardTableviewCell: UITableViewCell {

    @IBOutlet weak var contentbackgroundView: UIView!
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var storeContentLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
