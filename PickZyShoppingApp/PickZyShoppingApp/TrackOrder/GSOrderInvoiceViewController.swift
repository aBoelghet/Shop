//
//  GSOrderInvoiceViewController.swift
//  Shopor
//
//  Created by Ratheesh on 05/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderInvoiceViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var invoice_tableView: UITableView!
    
    var productsArray = [GSTrackOrderProductListProduct]()
    var productsData: GSTrackOrderProductListData?

    override func viewDidLoad() {
        super.viewDidLoad()

        applyColors()
        addFewIntializers()
    }

    // MARK: - Colors For UI
    
    private func applyColors() {
        
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        navigationBarView.titleText = ""
        
        let orderObject = productsData?.order
        
        if let orderId = orderObject?.orderId {
            navigationBarView.titleText = "Order Id: \(orderId)"
        }
        
        invoice_tableView.dataSource = self
        invoice_tableView.delegate = self
        
        invoice_tableView.register(UINib(nibName: GSString.NibNames.GSOrderInvoiceHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: GSOrderInvoiceHeaderView.identifier)
        invoice_tableView.estimatedSectionHeaderHeight = 44.0
        invoice_tableView.estimatedSectionFooterHeight = 44.0
        
        invoice_tableView.register(UINib(nibName: GSString.NibNames.GSViewBillingTableCell, bundle: nil), forCellReuseIdentifier: GSString.CellIdentifier.ViewBilling_tableCell)
        invoice_tableView.register(UINib(nibName: GSString.NibNames.GSOrderInvoiceFooterView, bundle: nil), forHeaderFooterViewReuseIdentifier: GSOrderInvoiceFooterView.identifier)
    }
}

// MARK: - UITableView Methods

extension GSOrderInvoiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.ViewBilling_tableCell) as? GSViewBillingTableCell else {
            return UITableViewCell()
        }
        
        cell.icon_imgView.image = #imageLiteral(resourceName: "tick_icon")
        
        let product = productsArray[indexPath.row]
        
        let unitOfProduct = (product.unit ?? "").removeEnclosedWhieteSpace()
        
        var productNameWithUnit = product.productName ?? ""
        
        if unitOfProduct != "" {
            productNameWithUnit.append(" | \(unitOfProduct)")
        }
        
        cell.productName_lbl.text = productNameWithUnit.removeEnclosedWhieteSpace()
        cell.quantity_lbl.text = " X " + "\(product.qty ?? 1)"
        let total_price = Double(product.qty ?? 1) * (product.sellingPrice ?? 0)
        cell.price_lbl.text = GSCommonHelper.formattedPrice(price: total_price)
        
        cell.icon_imgView.image = #imageLiteral(resourceName: "tick_icon")
        
        if let verifyStatus = product.verifyStatus {
        
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement || verifyStatus == TrackOrderConstants.VerifyStatus.undelivered {
                cell.icon_imgView.image = #imageLiteral(resourceName: "cross_invoice_icon")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSOrderInvoiceHeaderView.identifier) as? GSOrderInvoiceHeaderView else {
            return UIView()
        }
        
        let orderObject = productsData?.order
        
        let orderStatus = orderObject?.status ?? 0
        
        headerView.orderDelivered_lbl.isHidden = true
        
        let dateFormat = "dd MMM yyyy hh.mm a"
        
        if orderStatus == TrackOrderConstants.NewOrderStatus.Delivered.status || orderStatus == TrackOrderConstants.NewOrderStatus.Verified.status {
            headerView.orderDelivered_lbl.isHidden = false
            headerView.orderDelivered_lbl.text = "Order Delivered on " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.delivered, inputFormat: GSConstant.apiDateFormatter, reqFormat: dateFormat)
        }
        headerView.orderPlaced_lbl.text = "Order Placed on " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.ordered, inputFormat: GSConstant.apiDateFormatter, reqFormat: dateFormat)
        
        let shopObject = productsData?.shop
        let storeName = shopObject?.name ?? ""
        headerView.shopName_lbl.text = storeName
        headerView.shopAddress_lbl.text = shopObject?.address ?? ""
        
        headerView.cancelledOrRejected_lbl.text = ""
        
        if orderStatus == TrackOrderConstants.NewOrderStatus.Cancelled.status {
            headerView.cancelledOrRejected_lbl.text = "Cancelled by customer"
        } else if orderStatus == TrackOrderConstants.NewOrderStatus.Rejected.status {
            headerView.cancelledOrRejected_lbl.text = "Rejected by merchant"
        }
        
        var customerAddress = ""
        
        headerView.distance_lbl.text = GSCommonHelper.formattedDouble(double: productsData?.order?.distance ?? 0) + " km"
        
        if let customerAddressObject = productsData?.order?.address {
            
            if let street = customerAddressObject.street?.removeEnclosedWhieteSpace(), street != "" {
                customerAddress += (street + " ")
            }
            if let area = customerAddressObject.area?.removeEnclosedWhieteSpace(), area != "" {
                customerAddress += (area + "")
            }
            if let zipCode = customerAddressObject.zipcode?.removeEnclosedWhieteSpace(), zipCode != "" {
                customerAddress += zipCode
            }
        } else {
            customerAddress = "Self pick-up order"
        }
        headerView.customerAddress_lbl.text = customerAddress
        
        var customerName = ""
        
        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                
                let firstName = loginUser_jsonObject.userProfile?.firstName ?? ""
                let lastName = loginUser_jsonObject.userProfile?.lastName ?? ""
                
                customerName = (firstName + " " + lastName).removeEnclosedWhieteSpace()
            }
        }
        
        headerView.customerName_lbl.text = customerName
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSOrderInvoiceFooterView.identifier) as? GSOrderInvoiceFooterView else {
            return UIView()
        }
        
        footerView.cashBack_stackView.isHidden = true
        footerView.discount_stackView.isHidden = true
        
        var orderDiscountValue: Double = 0
        
        if let offerObject = productsData?.order?.offer, let offerType = offerObject.offerType, let offerValue = offerObject.offerAmount, offerValue != 0 {
            
            if offerType == GSConstant.offer_discount_type {
                footerView.discount_stackView.isHidden = false
                
                footerView.discountKey_lbl.text = "Discount Applied(\(offerObject.promoCode ?? ""))"
                footerView.discount_lbl.text = "-" + GSCommonHelper.formattedPrice(price: offerValue)
                orderDiscountValue = offerValue
                
            } else {
                footerView.cashBack_stackView.isHidden = false
                
                let orderStatus = productsData?.order?.status ?? 0
                
                var cashBackText = ""
                
                if orderStatus < TrackOrderConstants.NewOrderStatus.Delivered.status {
                    cashBackText = "Cashback Applied(\(offerObject.promoCode ?? ""))"
                } else {
                    cashBackText = "Cashback Applied(\(offerObject.promoCode ?? "")) - Credit on \(GSString.AppName) wallet"
                }
                
                footerView.cashBackKey_lbl.text = cashBackText
                footerView.cashBack_lbl.text = GSCommonHelper.formattedPrice(price: offerValue)
            }
        }
        
        footerView.GST_stackView.isHidden = true
        footerView.deliveryCharges_stackView.isHidden = true
        
        let pricesObject = productsData?.order?.prices
        
        let finalisedDiscount = getTotalDiscount(totalDiscount: productsData?.discountAmount ?? 0)
        
        var totalPrice = pricesObject?.grossPrice ?? 0
        
        if finalisedDiscount > 0 {
            totalPrice += finalisedDiscount
        }
 
        footerView.itemTotal_lbl.text = GSCommonHelper.formattedPrice(price: totalPrice)
        footerView.totalAmountKey_lbl.text = "Total Paid"

        if let paymentType = productsData?.order?.paymentType {
            
            if paymentType == 1 {
                let modeName = productsData?.order?.paymentModeName ?? "Online"
                footerView.totalAmountKey_lbl.text = "Total paid via \(modeName)"
            } else {
                
                let orderStatus = productsData?.order?.status ?? 0
                
                if orderStatus < TrackOrderConstants.NewOrderStatus.Delivered.status {
                    footerView.totalAmountKey_lbl.text = "Total amount to pay"
                } else {
                    footerView.totalAmountKey_lbl.text = "Total amount paid"
                }
            }
        }
        
        let totalAmount = ((pricesObject?.netPrice ?? 0) + (pricesObject?.delivery ?? 0) - orderDiscountValue)
        footerView.totalAmount_lbl.text = GSCommonHelper.formattedPrice(price: totalAmount)
        
        if let tax = pricesObject?.taxes, tax != 0 {
            footerView.GST_stackView.isHidden = false
            footerView.gst_lbl.text = GSCommonHelper.formattedPrice(price: tax)
        }
        
        if let deliveryFee = pricesObject?.delivery, deliveryFee != 0 {
            footerView.deliveryCharges_stackView.isHidden = false
            footerView.delivery_lbl.text = GSCommonHelper.formattedPrice(price: deliveryFee)
        }
        
        footerView.normalDiscount_stackView.isHidden = true
        
        if let totalDiscount = productsData?.discountAmount, totalDiscount != 0 {
            
            footerView.normalDiscount_stackView.isHidden = false
            
            let finalisedDiscount = getTotalDiscount(totalDiscount: totalDiscount)
            
            footerView.normalDiscount_lbl.text = "-" + GSCommonHelper.formattedPrice(price: finalisedDiscount)
        }
        
        return footerView
    }
    
    private func getTotalDiscount(totalDiscount: Double) -> Double {
        
        var tempTotalDiscount = totalDiscount
        
        for product in productsArray {
            
            if let verifyStatus = product.verifyStatus, verifyStatus == TrackOrderConstants.VerifyStatus.replacement || verifyStatus == TrackOrderConstants.VerifyStatus.undelivered {
                if let productOffer = product.offerPrice, productOffer != 0 {
                    tempTotalDiscount -= (productOffer * Double(product.escalatedQty ?? 0))
                }
            }
        }
        
        return tempTotalDiscount
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - NavigationBar Delegate Methods

extension GSOrderInvoiceViewController: NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
