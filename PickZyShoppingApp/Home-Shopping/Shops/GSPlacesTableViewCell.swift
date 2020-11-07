//
//  GSPlacesTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 29/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSPlaceTableCellDelegate:class {
    func saveSelectedAddress(_ sender:UIButton)
    func deleteSelectedAddress(_ sender:UIButton)
}

class GSPlacesTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var address_lbl: GSBaseLabel!
    @IBOutlet weak var location_lbl: GSBaseLabel!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var save_btn: UIButton!
    @IBOutlet weak var saveBtnBG_view:UIView!
    @IBOutlet weak var deleteBtnBG_view:UIView!
    @IBOutlet weak var icon_imgView:UIImageView!
    
    weak var delegate:GSPlaceTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func saveAction(_ sender: UIButton) {
        delegate?.saveSelectedAddress(sender)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        delegate?.deleteSelectedAddress(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
