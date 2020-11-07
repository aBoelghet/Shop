//
//  GSCategoryMenuView.swift
//  Shopor
//
//  Created by Ratheesh on 07/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSCategoryMenuViewDelegate:class {
    func categoryOrSubcategorySelectedWith(name:String?, isPathSearch:Bool)
}

class GSCategoryMenuView: NibView,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var categorySearchBar:GSSearchBar!
    @IBOutlet weak var category_tableView:UITableView!
    @IBOutlet weak var tableBG_view:GSCornerEdgeView!
    @IBOutlet weak var back_btn:UIButton!
    @IBOutlet weak var tableLeading_constraint:NSLayoutConstraint!
    @IBOutlet weak var offerProductsCount_lbl: GSBaseLabel!
    @IBOutlet weak var offerProduct_view: UIView!
    @IBOutlet weak var offerMainBg_view: UIView!
    
    var tableKeys_array = [String]()
    var dataSet_dictionary = [NSMutableDictionary]()
    
    let topLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.top
    let bottomLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.bottom
    
    var offerCount = 0
    
    weak var delegate:GSCategoryMenuViewDelegate?
    
    var categoryStringArray = [String]()

    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    // MARK: - Setting up the View
    
    private func setUpThisView() {
        category_tableView.dataSource = self
        category_tableView.delegate = self
        
        categorySearchBar.delegate = self
        back_btn.isHidden = true
        offerProduct_view.isHidden = true
        offerMainBg_view.isHidden = true
        
        let cellNib = UINib(nibName: GSString.NibNames.GSCategoryMenuTableCell, bundle: nil)
        category_tableView.register(cellNib, forCellReuseIdentifier: GSString.CellIdentifier.categoryMenuTableCell)
        category_tableView.tableFooterView = UIView()
        
        self.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 2.0, shadowOffset: CGSize(width: 2, height: 0))

        let font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 12)
        let textFieldPlaceHolder = categorySearchBar.value(forKey: "searchField") as? UITextField
        textFieldPlaceHolder?.font = font
        addGestures()
        
        tableBG_view.alpha = 0
    }
    
    // MARK: - Intialize the Data
    func intializeTheData(categoryDict : NSMutableDictionary) {
        
        if let string_array = Array(categoryDict.allKeys) as? [String] {
            self.tableKeys_array = string_array
        }
        back_btn.isHidden = true
        
        categoryStringArray = [String]()
        dataSet_dictionary = [NSMutableDictionary]()
        dataSet_dictionary.append(categoryDict)
        category_tableView.reloadData()
    }
    
    func updateOfferProductView() {
        offerProduct_view.isHidden = true
        offerMainBg_view.isHidden = true
        
        if dataSet_dictionary.count == 1 {
            offerMainBg_view.isHidden = true
        } else {
            offerMainBg_view.isHidden = false
        }
        
        if offerCount != 0, dataSet_dictionary.count == 1 {
            offerMainBg_view.isHidden = false
            offerProduct_view.isHidden = false
            offerProductsCount_lbl.text = "\(offerCount)"
        }
    }

    // MARK: - View Reuired Methods
    
    func showTheViewOn (_ parentView:UIView) {
        
        endEditing(true)
        
        initThisViewWithParent(parentView)
        
//        let tableWidth = category_tableView.frame.size.width
//        tableLeading_constraint.constant = -tableWidth
//        layoutIfNeeded()
//        tableLeading_constraint.constant = 0
        
//        UIView.animate(withDuration: 0.25, animations: {
//
//            self.layoutIfNeeded()
//
//        },completion: { _ in
//            UIView.animate(withDuration: 0.4, animations: {
//                //                self.menuBG.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            },completion: nil)
//        })
        
        //        let screen: CGRect = UIScreen.main.bounds
        //        frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + topLayoutGuideLength, width: screen.size.width, height: screen.size.height - topLayoutGuideLength - bottomLayoutGuideLength)
        //
        //        UIView.animate(withDuration: 0.45, animations: {  _ in
        //            self.frame = CGRect(x: screen.origin.x, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
        //
        //            self.initThisViewWithWindow(window)
        //
        //        },completion: { _ in
        //            UIView.animate(withDuration: 0.4, animations: {
        //            },completion: nil)
        //        })
        
        UIView.animate(withDuration: 0.4) {
            self.tableBG_view.alpha = 1.0
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func initThisViewWithParent(_ theView:UIView) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: theView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: theView, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: theView, attribute: .top, multiplier: 1, constant: topLayoutGuideLength)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: theView, attribute: .bottom, multiplier: 1, constant: -bottomLayoutGuideLength)
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    func showTheViewOn (_ window:UIWindow) {

        endEditing(true)
        
        initThisViewWithWindow(window)
        
        let tableWidth = category_tableView.frame.size.width
        tableLeading_constraint.constant = -tableWidth
        layoutIfNeeded()
        tableLeading_constraint.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: {  
            
            self.layoutIfNeeded()
            
        },completion: { _ in
            UIView.animate(withDuration: 0.4, animations: {
                //                self.menuBG.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            },completion: nil)
        })
        
//        let screen: CGRect = UIScreen.main.bounds
//        frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + topLayoutGuideLength, width: screen.size.width, height: screen.size.height - topLayoutGuideLength - bottomLayoutGuideLength)
//
//        UIView.animate(withDuration: 0.45, animations: {  _ in
//            self.frame = CGRect(x: screen.origin.x, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
//
//            self.initThisViewWithWindow(window)
//
//        },completion: { _ in
//            UIView.animate(withDuration: 0.4, animations: {
//            },completion: nil)
//        })
    }
    
    func initThisViewWithWindow(_ theWindow:UIWindow) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: theWindow, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: theWindow, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: theWindow, attribute: .top, multiplier: 1, constant: topLayoutGuideLength)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: theWindow, attribute: .bottom, multiplier: 1, constant: -bottomLayoutGuideLength)
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }

    // MARK: - Gesture methods
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureAction(_ sender:UITapGestureRecognizer) {
        
        closeThisViewWithAnimation {
            // Nothing to do here with completion
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: tableBG_view))! {
            return false
        }
        return true
    }
    
    // MARK: - Action Methods
    
    @IBAction func backAction(_ sender:UIButton) {
        
        if categoryStringArray.count > 0 {
            categoryStringArray.removeLast()
        }

        if dataSet_dictionary.count > 1 {
            searchBarChanges()
            dataSet_dictionary.removeLast()
            back_btn.isHidden = (dataSet_dictionary.count == 1)
            updateOfferProductView()
            guard let dictionaryFromStack = dataSet_dictionary.last else { return }
            guard let string_array = Array(dictionaryFromStack.allKeys) as? [String] else { return }
            tableKeys_array = string_array
            
            UIView.transition(with: category_tableView, duration: 0.45, options: .transitionCrossDissolve, animations: {
                self.category_tableView.reloadData()
            }) { _ in }
            
        }
    }
    
    @IBAction func offerProducts_action(_ sender: UIButton) {
        
        closeThisViewWithAnimation {
            self.delegate?.categoryOrSubcategorySelectedWith(name: "Offer Products", isPathSearch: false)
        }
    }
}

// MARK: - UISearchBar Delegate Methods

extension GSCategoryMenuView:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let dictionaryFromStack = dataSet_dictionary.last else { return }
        guard let string_array = Array(dictionaryFromStack.allKeys) as? [String] else { return }
        
        if searchBar.text?.count != 0 {
            
            guard let unwrappedSearbarText = searchBar.text else { return }
            tableKeys_array = string_array.filter({$0.lowercased().contains(unwrappedSearbarText.lowercased())})
            
        } else {
            tableKeys_array = string_array
        }
        
        category_tableView.reloadData()
    }
}

// MARK:- TableView Delegates

extension GSCategoryMenuView:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableKeys_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.categoryMenuTableCell) as? GSCategoryMenuTableCell else {
            return UITableViewCell()
        }
        let keyAtIndex = tableKeys_array[indexPath.row]
        
        var nextSubCategoryForThisKey = NSMutableDictionary()
        if let dictionaryFromStack = dataSet_dictionary.last {
            if let nextSubCategory = dictionaryFromStack[keyAtIndex] as? NSMutableDictionary {
                nextSubCategoryForThisKey = nextSubCategory
            }
        }
        
        cell.accessory_btn.isHidden = true
        cell.accessoryBtn_imgView.isHidden = true
        
        if nextSubCategoryForThisKey.count != 0 {
            cell.accessory_btn.isHidden = false
            cell.accessoryBtn_imgView.isHidden = false
        }
        
        cell.categoryName_lbl.text = keyAtIndex //Array(categoryDictionary!)[indexPath.row].key as? String // categories[indexPath.row]
        cell.accessory_btn.tag = indexPath.row
        cell.accessory_btn.addTarget(self, action: #selector(cell_accessoryAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let keyAtIndex = tableKeys_array[indexPath.row]
        
        categoryStringArray.append(keyAtIndex)
        
        var categoryString = categoryStringArray.joined(separator: "/")
        
//        if categoryString.first != "/" {
//            categoryString.insert("/", at: categoryString.startIndex)
//        }
        
        // We may have the full path or partial path in the category string as per the selection...
        // Will check whether the selected key is having values in the further neseted dictionary
        
        var isPathSearch = true
        
        if let dictionaryFromStack = dataSet_dictionary.last, let valueForThatKey = dictionaryFromStack[keyAtIndex] as? [String:Any], valueForThatKey.count > 0 {
            isPathSearch = false
            categoryString = keyAtIndex
        }
        
        closeThisViewWithAnimation {
            self.delegate?.categoryOrSubcategorySelectedWith(name: categoryString, isPathSearch: isPathSearch)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if dataSet_dictionary.count != 1 {
            return nil
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        let allLabel = UILabel()
        allLabel.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont.systemFont(ofSize: 17) : UIFont.systemFont(ofSize: 14)
        allLabel.textColor = UIColor.black
        headerView.addSubview(allLabel)
        
        let icon_imageView = UIImageView()
        icon_imageView.contentMode = .scaleAspectFit
        icon_imageView.image = #imageLiteral(resourceName: "shopInCategoryMenu_icon")
        headerView.addSubview(icon_imageView)
        
        allLabel.translatesAutoresizingMaskIntoConstraints = false
        icon_imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let allLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[imgView(15)]-10-[allLabel]-|", options: .directionLeadingToTrailing, metrics: nil, views: ["allLabel":allLabel, "imgView":icon_imageView])
        let allLabelVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[allLabel]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["allLabel":allLabel])
        let imgViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imgView]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["imgView":icon_imageView])
        NSLayoutConstraint.activate(imgViewVerticalConstraints)
        NSLayoutConstraint.activate(allLabelConstraints)
        NSLayoutConstraint.activate(allLabelVerticalConstraints)
        
        allLabel.text = "All"
        
        let allBtn = UIButton()
        headerView.addSubview(allBtn)
        
        allBtn.translatesAutoresizingMaskIntoConstraints = false
        let allBtnConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[allBtn]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["allBtn":allBtn])
        let allBtnVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[allBtn]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["allBtn":allBtn])
        NSLayoutConstraint.activate(allBtnConstraints)
        NSLayoutConstraint.activate(allBtnVerticalConstraints)
        
        allBtn.addTarget(self, action: #selector(cellHeader_allBtnSelection(_:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if dataSet_dictionary.count == 1 {
            return 40
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    // MARK: - Cell Action Methods
    @objc func cell_accessoryAction(_ sender:UIButton) {
        
        searchBarChanges()
        
        let index = sender.tag
        let keyAtIndex = tableKeys_array[index]
        
        guard let dictionaryFromStack = dataSet_dictionary.last else { return }
        guard let dictionaryAtIndex = dictionaryFromStack[keyAtIndex] as? NSMutableDictionary else { return }
        
        if dictionaryAtIndex.count == 0 {
            return
        }
        
        guard let string_array = Array(dictionaryAtIndex.allKeys) as? [String] else { return }
        
        dataSet_dictionary.append(dictionaryAtIndex)
        back_btn.isHidden = false
        tableKeys_array = string_array
        
        categoryStringArray.append(keyAtIndex)
        
        updateOfferProductView()
        
        UIView.transition(with: category_tableView, duration: 0.45, options: .transitionCrossDissolve, animations: {
            self.category_tableView.reloadData()
        }) { _ in }
    }
    
    @objc private func cellHeader_allBtnSelection(_ sender:UIButton) {
        closeThisViewWithAnimation {
            self.delegate?.categoryOrSubcategorySelectedWith(name: nil, isPathSearch: false)
        }
    }
    
    // MARK: - Closing This View With Animation
    
    fileprivate func closeThisViewWithAnimation(completion:@escaping ()->()) {
        
        if dataSet_dictionary.count > 0 {
            dataSet_dictionary.removeAll()
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.tableBG_view.alpha = 0
            self.backgroundColor = UIColor.clear
        }) { _ in
            completion()
            self.removeFromSuperview()
        }
        
        
//        let screen: CGRect = UIScreen.main.bounds
//        UIView.animate(withDuration: 0.45, animations: {
//            self.frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
//        },completion: {  _ in
//
//            self.removeFromSuperview()
//            completion()
//        })
    }
    
    // MARK: - Search Bar Changes
    fileprivate func searchBarChanges() {
        categorySearchBar.text = ""
        endEditing(true)
    }
}





