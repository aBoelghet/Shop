//
//  GSAddPaymentTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/30/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSAddPaymentTableCell: UITableViewCell {
    
    @IBOutlet var walletLabel:GSBaseLabel!
    @IBOutlet var walletImageView:UIImageView!
    @IBOutlet var shadowView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell() {
        
        walletLabel.textColor = UIColor(hexString: defaultTheme.paymentType_cell_text)
        shadowView.backgroundColor = UIColor(hexString: defaultTheme.paymentType_cell_bg)
        backgroundColor = UIColor(hexString: defaultTheme.paymentType_table_bg)
    }
    
    func configureTheCell(_ tempStr:String,_ images:UIImage) {
        walletLabel.text = tempStr
        walletImageView.image = images
    }
}
