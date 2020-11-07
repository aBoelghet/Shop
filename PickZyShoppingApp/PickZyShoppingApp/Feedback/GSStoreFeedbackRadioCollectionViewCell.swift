//
//  GSStoreFeedbackRadioCollectionViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 04/05/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSStoreFeedbackRadioCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var feedBackoptionLbl: GSBaseLabel!
    @IBOutlet weak var radioImage: UIImageView!
    
    func applyColors() {
        
        //        backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_BG)
        
        feedBackoptionLbl.textColor = UIColor(hexString: defaultTheme.LastOrderPopUpView_radioBtnTitle)
    }
}
