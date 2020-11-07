//
//  GSProductDetailsWithOfferPopUpView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 30/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDetailsWithOfferPopUpView: NibView {
    
    let cell_identifier = "productOfferCell"
    
    @IBOutlet weak var details_tableView: UITableView!
    @IBOutlet weak var bgview_heightConstraint:NSLayoutConstraint!
    @IBOutlet weak var bgView_topConstraint: NSLayoutConstraint!
    
    static let infoLabelHeight:CGFloat = 50
    static let estimatedCellHeight:CGFloat = 100
    
    var selectedProducts_array = [[String:Any]]()
    fileprivate var products_dictionary = [String:Int]()
    
    var isSendingModel = false
    var newProductModel:GSCartListNewData?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    // MARK: - Setting up this view
    
    private func setUpThisView() {
        
        details_tableView.register(UINib(nibName: GSString.NibNames.GSProductDetailsWithOfferTableCell, bundle: nil), forCellReuseIdentifier: cell_identifier)
        
        details_tableView.delegate = self
        details_tableView.dataSource = self
        
        details_tableView.tableFooterView = UIView()
        
    }
    
    // MARK: - Initialize the Data
    
    func initializeDataAndLoadUI(products_array: [[String:Any]], products_dic:[String:Int]) {
        
        self.selectedProducts_array = products_array
        
        products_dictionary = products_dic
        
        reloadTableAndFixTheViewHeight()
    }
    
    // MARK: - Intialize the data from cart
    func initializeProductModel(model:GSCartListNewData) {
        
        isSendingModel = true
        newProductModel = model
        
        guard var unwrapped_model = newProductModel else { return }
        guard var store_array = unwrapped_model.stores else { return }
        
        // Add availble qty to newProductModel array
        unwrapped_model.stores?.removeAll()
        for index in 0..<store_array.count {
            
            let selectedQuantity = store_array[index].productDetails?.qty ?? 0
            if selectedQuantity > 0 {
                unwrapped_model.stores?.append(store_array[index])
            }
        }
        newProductModel = unwrapped_model
        reloadTableAndFixTheViewHeight()
    }
    
    func showTheViewOn (_ parenView:UIView) {
        
        parenView.addSubview(self)
        
        initThisViewWithConstraints(parenView)
        
        let heightOfParent = parenView.frame.size.height
        bgView_topConstraint.constant = heightOfParent
        layoutIfNeeded()
        self.bgView_topConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layoutIfNeeded()
            
        },completion: { _ in
            
        })
    }
    
    func initThisViewWithConstraints(_ parenView:UIView) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let topLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.top
        let bottomLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.bottom
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: parenView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: parenView, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: parenView, attribute: .top, multiplier: 1, constant: topLayoutGuideLength)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: parenView, attribute: .bottom, multiplier: 1, constant: -bottomLayoutGuideLength)
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    private func reloadTableAndFixTheViewHeight() {
        
        details_tableView.reloadData()
        self.layoutIfNeeded()
        
        DispatchQueue.main.async {
            
            let numberOfRows = self.details_tableView.numberOfRows(inSection: 0)
            
            let totalRequiredHeight = (CGFloat(numberOfRows) * GSProductDetailsWithOfferPopUpView.estimatedCellHeight) + GSProductDetailsWithOfferPopUpView.infoLabelHeight
            
            let someOffsetToDifferentiateParnetAndChild:CGFloat = 80
            
            if totalRequiredHeight > self.frame.size.height + someOffsetToDifferentiateParnetAndChild {
                
                self.bgview_heightConstraint.constant = self.frame.size.height - someOffsetToDifferentiateParnetAndChild
                
            } else {
                self.bgview_heightConstraint.constant = totalRequiredHeight
            }
            
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Methods
    @IBAction func closeThisView(_ sender: UIButton) {
                
        let height = frame.size.height
        bgView_topConstraint.constant = 0
        layoutIfNeeded()
        self.bgView_topConstraint.constant = height
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.clear
            self.layoutIfNeeded()
            
        },completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    fileprivate func caluculatePriceWithOffer(_ original_price:Double, offer: Double) -> Double {
        if offer == 0 {
            return original_price
        }
        let costOfOffer = (original_price) * (offer/100)
        return (original_price) - costOfOffer
    }
}

extension GSProductDetailsWithOfferPopUpView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSendingModel {
            return newProductModel?.stores?.count ?? 0
        }
        return products_dictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSendingModel {
            return cellForCartListModelObject(indexPath: indexPath)
        } else {
            return cellForJsonObject(indexPath: indexPath)
        }
    }
    
    private func cellForJsonObject(indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = details_tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? GSProductDetailsWithOfferTableCell else {
            return UITableViewCell()
        }
        
        let itemAtIndex = selectedProducts_array[indexPath.row]
        
        let store_id = itemAtIndex[APIKeys.ProductDetails.Response.store_id] as? String ?? ""
        
        if let product_detials = itemAtIndex[APIKeys.ProductDetails.Response.product_details] as? [String:Any] {
            
            let selling_price = product_detials[APIKeys.ProductDetails.Response.selling_price] as? Double ?? Double(0)
            
            let offer = product_detials[APIKeys.ProductDetails.Response.offer] as? Double ?? Double(0)
            
            var final_price = selling_price
            let selectedStock = products_dictionary[store_id] ?? 0
            
            cell.quantity_lbl.text = "\(selectedStock)"
            
            cell.originalPriceStrikedLblBG_view.isHidden = true
            cell.offer_stackView.isHidden = true
            cell.priceWithOffer_lbl.isHidden = false
            cell.sellerName_lbl.text = "Store \(indexPath.row + 1)"
            
            if offer > 0 {
                
                cell.originalPriceStrikedLblBG_view.isHidden = false
                cell.offer_stackView.isHidden = false
                cell.priceWithOffer_lbl.isHidden = true
                
                final_price = caluculatePriceWithOffer(selling_price, offer: offer)
                
                cell.originalPriceStriked_lbl.text = GSCommonHelper.formattedPrice(price: selling_price * Double(selectedStock)) //GSConstant.currency_symbol + " \(selling_price * Double(selectedStock))"
                cell.offer_lbl.text = "\(offer)%"
                cell.priceWithOffer_lbl.text = GSCommonHelper.formattedPrice(price: final_price * Double(selectedStock)) //GSConstant.currency_symbol + " \(final_price * Double(selectedStock))"
                cell.priceWithOfferFinal_lbl.text = GSCommonHelper.formattedPrice(price: final_price * Double(selectedStock)) //GSConstant.currency_symbol + " \(final_price * Double(selectedStock))"
            } else {
                cell.priceWithOffer_lbl.text = GSCommonHelper.formattedPrice(price: selling_price * Double(selectedStock)) //GSConstant.currency_symbol + " \(selling_price * Double(selectedStock))"
                //                cell.priceWithOfferFinal_lbl.text = GSConstant.currency_symbol + " \(selling_price * Double(selectedStock))"
                cell.priceWithOfferFinal_lbl.text = ""
            }
        }
        return cell
    }
    
    private func cellForCartListModelObject(indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = details_tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? GSProductDetailsWithOfferTableCell else {
            return UITableViewCell()
        }
        
        guard let unwrappedProductModel = newProductModel else { return UITableViewCell() }
        guard let store_array = unwrappedProductModel.stores else { return UITableViewCell() }
        
        let productAtIndex = store_array[indexPath.row]
        
        var offer:Double = 0
        
        if let unwrapped_offer = productAtIndex.productDetails?.offer {
            offer = Double(unwrapped_offer)
        }
        
        let quantity = productAtIndex.productDetails?.qty ?? 0
        
        cell.quantity_lbl.text = "\(quantity)"
        
        cell.originalPriceStrikedLblBG_view.isHidden = true
        cell.offer_stackView.isHidden = true
        cell.priceWithOffer_lbl.isHidden = false
        cell.sellerName_lbl.text = "Store \(indexPath.row + 1)"
        
        let singlePieceOriginal_price = Double(productAtIndex.productDetails?.sellingPrice ?? 0)
        let original_price:Double = singlePieceOriginal_price * Double(quantity)
        var final_price:Double = original_price
        if offer != 0 {
            final_price = caluculatePriceWithOffer(singlePieceOriginal_price, offer: offer) * Double(quantity)
            
            cell.originalPriceStrikedLblBG_view.isHidden = false
            cell.offer_stackView.isHidden = false
            cell.priceWithOffer_lbl.isHidden = true
            
            cell.originalPriceStriked_lbl.text = GSCommonHelper.formattedPrice(price: original_price) //GSConstant.currency_symbol + " \(original_price)"
            cell.offer_lbl.text = "\(offer)%"
            cell.priceWithOffer_lbl.text = GSCommonHelper.formattedPrice(price: final_price) //GSConstant.currency_symbol + " \(final_price)"
            cell.priceWithOfferFinal_lbl.text = GSCommonHelper.formattedPrice(price: final_price) //GSConstant.currency_symbol + " \(final_price)"
            
        } else {
            cell.priceWithOffer_lbl.text = GSCommonHelper.formattedPrice(price: original_price) //GSConstant.currency_symbol + " \(original_price)"
            //                cell.priceWithOfferFinal_lbl.text = GSConstant.currency_symbol + " \(selling_price * Double(selectedStock))"
            cell.priceWithOfferFinal_lbl.text = ""
        }
        return cell
    }
}
