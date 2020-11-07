//
//  DeliveryAddressTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 24/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class DeliveryAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var address_Label: UILabel!
    
    @IBOutlet weak var address_radioButton: UIButton!
    
    @IBOutlet weak var address_EditButton: UIButton!
    
    @IBOutlet weak var address_radioImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Configuring The Cell
    
    func configureTheCell(address:String, specifiedString:String, zipCode:String, landMark:String, indexPath:IndexPath) {
//        title_lbl.text = "Address"
        let landMarkVar = (landMark == "") ? "" : "Landmark: \(landMark)"
        
        var fullAddress = ""
        
        if specifiedString != "" {
            fullAddress += specifiedString
        }
        
        if address != "" {
            
            if fullAddress == "" {
                fullAddress += address
            } else {
                fullAddress += "\n\(address)"
            }
        }
        
        if zipCode != "" {
            
            if fullAddress == "" {
                fullAddress += zipCode
            } else {
                fullAddress += "\n\(zipCode)"
            }
        }
        
        if landMarkVar.removeEnclosedWhieteSpace() != "" {
            
            if fullAddress == "" {
                fullAddress += landMarkVar
            } else {
                fullAddress += "\n\(landMarkVar)"
            }
        }
        
        address_Label.text = fullAddress
        
        //        let selectedDeliveryType = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        //
        //        if selectedDeliveryType == GSConstant.defaultDeliveryMethod_id {    // Delivery By Shop
        //
        //            edit_btn.isHidden = false
        //
        //        } else {
        //            edit_btn.isHidden = true
        //        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
