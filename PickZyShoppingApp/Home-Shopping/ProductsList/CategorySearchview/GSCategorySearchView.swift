//
//  GSCategorySearchView.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 07/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation


protocol  GSCategorySelectDelegate : class{
    func categorySelectAction(index: Int)
    func productSelectAction( index: Int, productsArr : [GSProductsList])
}

class GSCategorySearchView : NibView{
    
    @IBOutlet weak var categoryTable: UITableView!
    
    var delegate : GSCategorySelectDelegate?
    
    var categories : [String]?
    
    var searchedProductsArr : [GSProductsList]?
    
    let productRowHeight : CGFloat = 80
    let categoryRowHeight : CGFloat = 50
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    func setUpThisView()    {
        
        let simpleRowCellNib = UINib.init(nibName: GSString.NibNames.GSProductSearchTableCell, bundle: nil)
        categoryTable.register(simpleRowCellNib, forCellReuseIdentifier: GSString.CellIdentifier.ProductSearch_tableCell)
        
        categoryTable.dataSource = self
        categoryTable.delegate = self
    }
}

extension GSCategorySearchView : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if let cat  = searchedProductsArr {
                return cat.count
            }
        } else {
            if let cat  = categories {
                return cat.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.ProductSearch_tableCell, for: indexPath) as! GSProductSearchTableViewCell
        
        if indexPath.section == 0   {
            
            var price = ""
            if let unwrappedPrice = searchedProductsArr?[indexPath.row].stores?[0].product_details?.selling_price {
                price = "₹\(unwrappedPrice)"
            }
            
            let title = "\(searchedProductsArr?[indexPath.row].productInfo?.product_name ?? "")"
            let priceVal = "\n\(searchedProductsArr?[indexPath.row].productInfo?.unit ?? "")  |  \(price)"
            
             cell.name.attributedText = String().getAttributedString(firstString: title, firstFont: UIFont.boldSystemFont(ofSize: 15), firstColor: UIColor.black, secondString: priceVal, secondFont: UIFont.systemFont(ofSize: 14), secondColor: UIColor.black)
            
            
            let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
            cell.product_icon.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + (searchedProductsArr?[indexPath.row].productInfo?.images![0].name)!+imgHeight) , placeholderImage: #imageLiteral(resourceName: "Pickzy_logo"), completed: nil)
            
            cell.imageIconWidth.constant = 70
            cell.product_icon.isHidden = false
            cell.quantityViewWidth.constant = 0
            cell.quantityView.isHidden = false
            
            cell.addCartButton.tag = indexPath.row
            cell.addCartButton.addTarget(self, action: #selector(AddCartButtonAction(_:)), for: .touchUpInside)
        } else {
            
            if (categories!.count > indexPath.row) {
                cell.name.text = categories?[indexPath.row]
                cell.imageIconWidth.constant = 0
                cell.product_icon.isHidden = true
                cell.quantityViewWidth.constant = 0
                cell.quantityView.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Category"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if searchedProductsArr != nil {
                return 80
            }
        } else {
            if categories != nil {
                return 50 // UITableViewAutomaticDimension
            }
        }
        return 80
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeFromSuperview()
        if indexPath.section == 0   {
            delegate?.productSelectAction(index: indexPath.row, productsArr: searchedProductsArr!)
        } else {
        delegate?.categorySelectAction(index: indexPath.row)
        }
    }

    @objc private func AddCartButtonAction(_ sender: UIButton) {
        
    }
}
