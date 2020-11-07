//
//  TrackOrderRowListCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSTrackOrderRowListTableCell: UITableViewCell {
    
    @IBOutlet weak var shop_imageView: UIImageView!
    @IBOutlet weak var storeAddress_lbl: GSBaseLabel!
    @IBOutlet weak var orderCount_lbl: GSBaseLabel!
    @IBOutlet weak var trackOrder_btn: UIButton!
    @IBOutlet weak var openInMaps_btn: UIButton!
    @IBOutlet weak var contact_btn:UIButton!
    @IBOutlet weak var cost_lbl:GSBaseLabel!
    @IBOutlet weak var orderIdValue_lbl: GSBaseLabel!
    @IBOutlet weak var orderPlacedTime_lbl: GSBaseLabel!
    
    @IBOutlet weak var orderIdKey_lbl: GSBaseLabel!
    @IBOutlet weak var orderPlacedKey_lbl: GSBaseLabel!
    
    @IBOutlet weak var expectedDeliveryKey_lbl: GSBaseLabel!
    @IBOutlet weak var expectedDeliveryValue_lbl: GSBaseLabel!
    
    @IBOutlet weak var expectedDelivery_stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Configuring The Cell
    
    func configureTheCell(orderDetails:New_GSTrackOrderListOrder) {
        
        cost_lbl.text = ""
        
        let netPrice = orderDetails.amount ?? 0
        
        cost_lbl.text = GSCommonHelper.formattedPrice(price: netPrice)
        
        if let offerObject = orderDetails.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            cost_lbl.text = GSCommonHelper.formattedPrice(price: netPrice - (offerObject.offerAmount ?? 0))
        }
        
        storeAddress_lbl.text = "Address:\n\(orderDetails.shop?.address ?? "")"
        orderCount_lbl.text = "\(orderDetails.products ?? 0)"
        
        orderIdValue_lbl.text = orderDetails.orderID
        orderPlacedKey_lbl.text = "Order status:"
        orderPlacedTime_lbl.text = orderStatus(objectAtIndex: orderDetails)
        
        expectedDelivery_stackView.isHidden = true
        
        if orderDetails.expectedTime?.at != nil {
            
            expectedDelivery_stackView.isHidden = false
            
            expectedDeliveryValue_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderDetails.expectedTime?.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: "dd-MM-yyyy hh:mm a")
        }
    }
    
    fileprivate func orderStatus(objectAtIndex: New_GSTrackOrderListOrder) -> String {
        
        if let orderStatus = objectAtIndex.status {
            
            switch orderStatus {
                
            case TrackOrderConstants.NewOrderStatus.Ordered.status:
                return TrackOrderConstants.NewOrderStatus.Ordered.name
                
            case TrackOrderConstants.NewOrderStatus.Accepted.status:
                return TrackOrderConstants.NewOrderStatus.Accepted.name
                
            case TrackOrderConstants.NewOrderStatus.ReadyToShip.status:
                return TrackOrderConstants.NewOrderStatus.ReadyToShip.name
                
            case TrackOrderConstants.NewOrderStatus.Rejected.status:
                return TrackOrderConstants.NewOrderStatus.Rejected.name
                
            case TrackOrderConstants.NewOrderStatus.Cancelled.status:
                return TrackOrderConstants.NewOrderStatus.Cancelled.name
                
            case TrackOrderConstants.NewOrderStatus.Shipping.status:
                return TrackOrderConstants.NewOrderStatus.Shipping.name
                
            case TrackOrderConstants.NewOrderStatus.Delivered.status:
                return TrackOrderConstants.NewOrderStatus.Delivered.name
                
            case TrackOrderConstants.NewOrderStatus.Verified.status:
                return TrackOrderConstants.NewOrderStatus.Verified.name
                
            default:
                return "NA"
            }
        }
        return "NA"
    }
    
    func getDateInTheSimpleFormat(dateStr:String?) -> String {
        
        guard let unwrappedString = dateStr else { return "NA" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: unwrappedString) ?? Date()
        
        let anotherDateFormatter = DateFormatter()
        anotherDateFormatter.dateFormat = "hh:mm a"
        
        return anotherDateFormatter.string(from: date)
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        contentView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderCell_Content_BG)
        orderCount_lbl.textColor = UIColor(hexString: defaultTheme.trackOrder_orderCountLabelText)
        storeAddress_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_text)
        contact_btn.layer.borderColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_contactBtn_border).cgColor
        contact_btn.setTitleColor(UIColor(hexString: defaultTheme.trackOrderListVC_cell_contactBtn_text), for: .normal)
        orderCount_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_orderCount_lbl_text)
        cost_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_cost_lbl_text)
        
        for orderKey_lbl in [orderIdKey_lbl, orderPlacedKey_lbl, expectedDeliveryKey_lbl] {
            orderKey_lbl?.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_orderKey_lbl_text)
        }
        
        for orderValue_lbl in [orderIdValue_lbl, orderPlacedTime_lbl, expectedDeliveryValue_lbl] {
            orderValue_lbl?.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_orderValue_lbl_text)
        }
    }
}
