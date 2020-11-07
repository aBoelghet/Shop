//
//  WalletAmountCollectionViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 25/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class WalletAmountCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cell_BackgroundView: UIView!
    
    @IBOutlet weak var walletAmount_Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cell_BackgroundView.layer.cornerRadius = 3
        cell_BackgroundView.clipsToBounds = true
        cell_BackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        cell_BackgroundView.layer.borderWidth = 1
    }

}
