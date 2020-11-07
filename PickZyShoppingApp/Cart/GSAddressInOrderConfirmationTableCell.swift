//
//  GSAddressInOrderConfirmationTableCell.swift
//  Shopor-dev
//
//  Created by Ratheesh on 16/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSAddressInOrderConfirmationCellDelegate:class {
    func radioButtonPressed(_ sender:UIButton)
    func editActionPressed(_ sender:UIButton)
}

class GSAddressInOrderConfirmationTableCell: UITableViewCell {

    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var address_lbl:GSBaseLabel!
    @IBOutlet weak var radio_btn: UIButton!
    @IBOutlet weak var edit_btn: UIButton!
    
    weak var delegate:GSAddressInOrderConfirmationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyColorsForUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Apply Colors
    
    private func applyColorsForUI() {
        address_lbl.textColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_cell_text)
        title_lbl.textColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_cell_header)
    }
    
    // MARK: - Configuring The Cell
    
    func configureTheCell(address:String, specifiedString:String, zipCode:String, landMark:String, indexPath:IndexPath) {
        title_lbl.text = "Address"
        let landMarkVar = (landMark == "") ? "" : "Landmark: \(landMark)"
        
        var fullAddress = ""
        
        if specifiedString != "" {
            fullAddress += specifiedString
        }
        
        if address != "" {
            
            if fullAddress == "" {
                fullAddress += address
            } else {
                fullAddress += "\n\n\(address)"
            }
        }
        
        if zipCode != "" {
            
            if fullAddress == "" {
                fullAddress += zipCode
            } else {
                fullAddress += "\n\n\(zipCode)"
            }
        }
        
        if landMarkVar.removeEnclosedWhieteSpace() != "" {
            
            if fullAddress == "" {
                fullAddress += landMarkVar
            } else {
                fullAddress += "\n\n\(landMarkVar)"
            }
        }
        
        address_lbl.text = fullAddress

        radio_btn.tag = indexPath.row
        edit_btn.tag = indexPath.row
        
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
    
    // MARK: - Action Methods
    
    @IBAction func radioButton_action(_ sender:UIButton) {
        delegate?.radioButtonPressed(sender)
    }

    @IBAction func editAction(_ sender:UIButton) {
        delegate?.editActionPressed(sender)
    }
}
