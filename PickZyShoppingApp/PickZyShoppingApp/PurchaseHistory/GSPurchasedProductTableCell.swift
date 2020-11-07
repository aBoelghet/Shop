//
//  GSPurchasedProductTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/6/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPurchasedProductTableCell: UITableViewCell {
    
    @IBOutlet weak var shop_imageView:UIImageView!
    @IBOutlet weak var detail_lbl:GSBaseLabel!
    @IBOutlet weak var orderCount_lbl:GSBaseLabel!
    @IBOutlet weak var daysCount_lbl:GSBaseLabel!
    @IBOutlet weak var cost_lbl:GSBaseLabel!
    @IBOutlet weak var review_btn:GSBaseButton!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var replacementTitle_lbl:GSBaseLabel!
    @IBOutlet weak var writeReview_btn:UIButton!
    
    @IBOutlet weak var orderIdValue_lbl: GSBaseLabel!
    @IBOutlet weak var orderIdKey_lbl: GSBaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        detail_lbl.textColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_info_text)
        orderCount_lbl.textColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_orderCount_text)
        daysCount_lbl.textColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_replacementValue_text)
        cost_lbl.textColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_cost_title)
        replacementTitle_lbl.textColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_replacement_title)
        
        writeReview_btn.setTitleColor(UIColor(hexString: defaultTheme.purchasedProducts_cell_reviewBtn_title), for: .normal)
        writeReview_btn.backgroundColor = UIColor(hexString: defaultTheme.purchasedProducts_cell_reviewBtn_BG)
        
        orderIdKey_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_orderKey_lbl_text)
        orderIdValue_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_orderValue_lbl_text)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        writeReview_btn.layer.masksToBounds = true
        writeReview_btn.layer.cornerRadius = 0.5 * writeReview_btn.frame.size.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func configureTheCell (_ orderDetailItem: New_GSPurchasedListDataOrder) {

        orderIdValue_lbl.text = orderDetailItem.orderID
        
        detail_lbl.text = orderDetailItem.shop?.address ?? ""
        
        orderCount_lbl.text = ""
        if let orderCount = orderDetailItem.products, orderCount != 0 {
            orderCount_lbl.text = "\(orderCount)"
        }
        
        daysCount_lbl.text = "NA"
        let replacementDaysObj = isReplaceMentExist(lastDateInString: orderDetailItem.shop?.replacement)
        
        if replacementDaysObj.0 == true {
            writeReview_btn.isHidden = false
            daysCount_lbl.text = replacementDaysObj.1
        } else {
            writeReview_btn.isHidden = true
            daysCount_lbl.text = "NA"
        }
        
        cost_lbl.text = ""
        cost_lbl.text = GSCommonHelper.formattedPrice(price: orderDetailItem.amount ?? 0)
        
        if let offerObject = orderDetailItem.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            cost_lbl.text = GSCommonHelper.formattedPrice(price: (orderDetailItem.amount ?? 0) - (offerObject.offerAmount ?? 0))
        }
    }
    
    private func isReplaceMentExist(lastDateInString:String?)->(Bool, String) {
        
        guard let unwrappedDatStr = lastDateInString else { return (false,"") }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GSConstant.apiDateFormatter
        guard let lastDateForReplacement = dateFormatter.date(from: unwrappedDatStr) else { return (false,"") }
        let currentDate = Date()
        
        let calenderComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate, to: lastDateForReplacement)
        
        let yearDiff = calenderComponents.year ?? 0
        let monthDiff = calenderComponents.month ?? 0
        let dayDiff = calenderComponents.day ?? 0
        let hourDiff = calenderComponents.hour ?? 0
        let minuteDiff = calenderComponents.minute ?? 0
        
        var isExist = false
        var toShow = ""
        if yearDiff > 0 {
            isExist = true
            toShow = "\(yearDiff) year(s) left"
        } else if monthDiff > 0 {
            isExist = true
            toShow = "\(monthDiff) month(s) left"
        } else if dayDiff > 0 {
            isExist = true
            if hourDiff <= 0 {
                toShow = "\(dayDiff) day(s) left"
            } else {
                toShow = "\(dayDiff + 1) day(s) left"
            }
        } else if hourDiff > 0 {
            isExist = true
            toShow = "\(hourDiff) hour(s) left"
        } else if minuteDiff > 0 {
            isExist = true
            toShow = "\(minuteDiff) min(s) left"
        }
        
        return (isExist, toShow)
    }
}








