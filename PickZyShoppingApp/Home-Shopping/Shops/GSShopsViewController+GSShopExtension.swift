//
//  GSShopsViewController+GSShopExtension.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 09/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
import GooglePlaces
import MKToolTip

extension GSShopsViewController:UITextFieldDelegate, GSPlaceAutoCompleteDelegate {
    
    // MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        if textField == deliveryLocation_txtField || textField == productSearchLocation_txtField {
//
//            UIView.animate(withDuration: 0.25, animations: { [weak self] in
//                self?.tfIndex = textField.tag
//                textField.resignFirstResponder()
//                }, completion: { [weak self] _ in
//
//                    if let pushVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPlacesAutoCompleteViewController) as? GSPlacesAutoCompleteViewController {
//                        pushVC.delegate = self
//                        if textField == self?.productSearchLocation_txtField {
//                            pushVC.type = 0
//                        } else {
//                            pushVC.type = 1
//                        }
//                        self?.present(pushVC, animated: true, completion: nil)
//                    }
//            })
//        }
        
        let tag = textField.tag
        if checkForTheCartExists(selectedTextFieldTag: tag) == false {
            showTheAutoCompleteLocationVC(selectedTextFieldTag: tag)
        }
    }
    
    func showTheAutoCompleteLocationVC(selectedTextFieldTag:Int) {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPlacesAutoCompleteViewController) as? GSPlacesAutoCompleteViewController {
            pushVC.delegate = self
            pushVC.type = selectedTextFieldTag
            GSCustomPushPop.doCustomPush(from: self, to: pushVC)
        }
    }
    
    func checkForTheCartExists(selectedTextFieldTag:Int) -> Bool {
        
        if cartCount.value > 0 {
            
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.locationChangeAlert, alertButtonsArray: ["Cancel","Continue"], isLastButtonDestructive: true, viewController: GSTopViewController.topViewController()) { (btnIndex) in
                
                if btnIndex == 1 {  // Conitnue
                    self.clearCartSupport = GSClearCartSupport()
                    self.clearCartSupport?.clearCartAPI()
                    self.clearCartSupport?.clearSaveForLaterAPI()
                    self.showTheAutoCompleteLocationVC(selectedTextFieldTag: selectedTextFieldTag)
                }
            }
            return true
        }
        return false
    }
}

// MARK: - TableView DataSource
extension GSShopsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return shopTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    #if DEBUG
    func resetTableCells() {
        
//        for sectionCount in 0...shopsListArray.count {
//            let indexPath = IndexPath(row: 0, section: sectionCount)
//            let cell = shopsCat_TableView.cellForRow(at: indexPath) as? GSShopCategoryTableCell
//            cell?.isCellFormed = false
//        }
        
        for sectionCount in 0...shopTypeArray.count {
            let indexPath = IndexPath(row: 0, section: sectionCount)
            let cell = shopsCat_TableView.cellForRow(at: indexPath) as? GSShopCategoryTableCell
            cell?.isCellFormed = false
        }
    }
    #endif
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.ShopVC_ShopCat_TableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSShopCategoryTableCell else {
            return UITableViewCell()
        }
       
        let type = shopTypeArray[indexPath.section]

//        if shopsListArray.count < indexPath.section || shopsListArray.count == 0 {
//            return cell
//        }
//        if shopTypeArray.count < indexPath.section {
//            return cell
//        }
        #if DEBUG
            print ("Crash track: ", indexPath.section)
        #endif
        
        let listArray = shopListDictionary[type.shopTypeId]
        
        var boolValue:Bool = true
        if type.shopTypeId == 0 {
            boolValue = false
        }
        cell.configureTheCell(displayCount: boolValue, shopsModel: listArray?.data?.category, tableIndex: indexPath.section, sectionId: type.shopTypeId)
        cell.offerNotifications_array = offerNotifications_array
        
        return cell
    }
}

// MARK: - TableView Delegate
extension GSShopsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let radius = searchRadius
        var isFullDescSectionNeeded:Bool = true
        
//        let type = shopTypeArray[section]
//
//        if let shopItem = shopListDictionary[type.shopTypeId] {
//
//            if let shopsArr = shopItem.data?.category! {
//
//                if shopsArr.count == 0 || radius/GSConstant.meterToKm != Int((radius_lbl.text?.numbersFromString())!) {
//                    if suggestionToshow == false {
//                        isFullDescSectionNeeded = false
//                    } else {
//                        isFullDescSectionNeeded = true
//                    }
//                } else {
//                    isFullDescSectionNeeded = false
//                }
//            }
//        }
        
        // We have to show the pop up only in first section... whatever the category
        if section != 0 || !isAllCategoriesEmpty {    // Full discription is not needed other than first section and if any category is having stores
            isFullDescSectionNeeded = false
        } else if !isAllCategoriesEmpty {             // Falls on this case if it is first section and categories having stores
            isFullDescSectionNeeded = false
        }
        
        isFullDescSectionNeeded = false
        
        if isAllCategoriesEmpty, section == 0 {
            isFullDescSectionNeeded = true
        }
        
//        if isGlobalShopsLoaded, section == 0 {
//            isFullDescSectionNeeded = true
//        }
        
        let shopTypeAtFirst = shopTypeArray[0]
        
        if shopTypeAtFirst.shopTypeId == globalShop_id, section == 0 {
            isFullDescSectionNeeded = true
        }
        
        if clickedCloseForNoShopInfo {
            isFullDescSectionNeeded = false
        }
        
        let headerBG_color = (section == 0) ? UIColor(hexString: defaultTheme.shopVC_header_BG1) : (section == 1) ? UIColor(hexString: defaultTheme.shopVC_header_BG2) : UIColor(hexString: defaultTheme.shopVC_header_BG3)
        
        if isFullDescSectionNeeded {
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as! GSShopCatCollectionHeaderView
            
            headerView.titleBg_view.backgroundColor = headerBG_color
            headerView.suggestionLabel.isHidden = true
            headerView.info_btn.tag = section
            headerView.info_btn.addTarget(self, action: #selector(cellHeaderInfoButtonAction(_:)), for: .touchUpInside)
            headerView.clickHere_btn.addTarget(self, action: #selector(clickHereWhenNoShopsAvailable(_:)), for: .touchUpInside)
            headerView.close_btn.addTarget(self, action: #selector(headerClose_action(_:)), for: .touchUpInside)
            if shopTypeArray.count > section {
                let shops = shopTypeArray[section]
                headerView.configureHeaderView(shops, rad: radius)
            }
            return headerView
        } else {

            let simpleHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "simpleHeaderView") as! GSShopCatCollectionSimpleHeaderView
            simpleHeaderView.titleBg_view.backgroundColor = headerBG_color
            simpleHeaderView.info_btn.tag = section
            simpleHeaderView.info_btn.addTarget(self, action: #selector(cellHeaderInfoButtonAction(_:)), for: .touchUpInside)
            simpleHeaderView.suggestionLabel.isHidden = true
            if shopTypeArray.count > section {
                simpleHeaderView.configureHeaderView(shopTypeArray[section], rad: radius)
            }
            return simpleHeaderView
        }
    }
    
    @objc private func cellHeaderInfoButtonAction(_ sender: UIButton) {
        
        let tag = sender.tag
        if tag < shopTypeArray.count {
            
            let category = shopTypeArray[tag]
            
            var messageToShow = ""
            
            switch category.shopTypeId {
            case 0: // Private
                messageToShow = GSConstant.ToolTip.privateShopInfo
                break
            case 1: // Public
                messageToShow = GSConstant.ToolTip.publicShopInfo
                break
            case 2: // Branded
                messageToShow = GSConstant.ToolTip.brandedShopInfo
                break
            case 3:
                messageToShow = GSConstant.ToolTip.globalShopInfo
                break
            default:
                break
            }
            
            // Decide the direction of pop based on the header position respective to view
            
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: shopsCat_TableView)
            let exactY_positionRespectToView = buttonPosition.y - shopsCat_TableView.contentOffset.y + shopsCat_TableView.frame.origin.y
            let screenMidY = 0.5 * view.frame.size.height
            
            var arrowPosition:MKToolTip.ArrowPosition = .top
            
            if exactY_positionRespectToView > screenMidY {
                arrowPosition = .bottom
            }
            
            addTooltip(sender, message: messageToShow, title: "", arrowPosition: arrowPosition)
        }
    }
    
    @objc private func headerClose_action(_ sender: UIButton) {
        clickedCloseForNoShopInfo = true
        shopsCat_TableView.reloadData()
    }
    
    @objc private func clickHereWhenNoShopsAvailable(_ sender:UIButton) {
        
        guard let url = URL(string: GSConstant.appWebsite_url) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    fileprivate func addTooltip(_ button:UIButton, message:String, title:String, arrowPosition:MKToolTip.ArrowPosition) {
        
        let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
        let preference = ToolTipPreferences()
        preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
        preference.drawing.arrow.tipCornerRadius = 0
        preference.drawing.message.color = .black
        
        if title != "" {
            toolTip = button.showToolTip(identifier: "", title: title, message: message, arrowPosition: arrowPosition, preferences: preference, delegate: nil)
        } else {
            toolTip = button.showToolTip(identifier: "", message: message, arrowPosition: arrowPosition, preferences: preference, delegate: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let viewWidth = self.view.frame.size.width
        
        var cellWidth = CGFloat()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            cellWidth = (viewWidth - 40) / 3.0
        } else {
            cellWidth = (viewWidth - 60) / 7.0
            var  remainder = Int(viewWidth.truncatingRemainder(dividingBy: cellWidth))
            while remainder > 5 {
                
                cellWidth = cellWidth - 1
                remainder = Int(viewWidth.truncatingRemainder(dividingBy: cellWidth+10))            // 10 is minimum inter item spacing...
            }
        }
        let cellHeight = cellWidth + 30             // 30 is for shop catgory name label
        let reqNoOfRows:CGFloat = 2
        
        let heightRequired = (cellHeight * reqNoOfRows) + (10 * (reqNoOfRows + 1))
        
        return heightRequired + 15.0
    }
    
    //MARK: UITableView User defined methods
//    @objc private func closeSectionAction(_ sender:UIButton) {
//
//        let section = sender.tag
//        shopsCat_TableView.reloadData()
//        suggestionToshow = false
//        let range = NSMakeRange(section, 1)
//        let sections = NSIndexSet(indexesIn: range)
//        shopsCat_TableView.reloadSections(sections as IndexSet, with: .none)
//    }
}

// MARK: - CLLocation Delegate
extension GSShopsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        guard let latestLocation = locations.first else { return }
        
        getTheAddressDetailsUsing(latestLocation, field: deliveryLocation_txtField)
        
        if let coordinates = locationManger.location?.coordinate {
            
            if SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) != nil && SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) != nil {
                return
            }
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLongitude, value: coordinates.longitude)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchLatitude, value: coordinates.latitude)
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: coordinates.longitude)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: coordinates.latitude)
            
            SharedPersistence.removeValue(key: UserDefaultKeys.locations.savedAddressObject)
            
            loadAddress()
            
//            self.requestShopsList(radius:self.searchRadius, recursionValue: 0)
            self.requestShopCategories()
        } else {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.unableToFetchLocation, viewController: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied, .restricted:
            //            CustomAlert.showAlert(title: GSString.AppName, message: "Unable to fetch current location. Please allow \(GSString.AppName) in settings to access your location.", viewController: self)
            break
        default:
            break
        }
    }
}

// Added By Venu...
// MARK: - Animation Methods for the view scroll having textfields
extension GSShopsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.locationBGHeight_constraint.constant
            if isScrollingDown {
                newHeight = max(minHeaderHeight, locationBGHeight_constraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(maxHeaderHeight, locationBGHeight_constraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.locationBGHeight_constraint.constant {
                self.locationBGHeight_constraint.constant = newHeight
                self.updateHeader()
                self.setScrollPosition(previousScrollOffset)
            }
            previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = maxHeaderHeight - minHeaderHeight
        let midPoint = minHeaderHeight + (range / 2)
        
        if self.locationBGHeight_constraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.locationBGHeight_constraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.locationBGHeight_constraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.locationBGHeight_constraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        shopsCat_TableView.contentOffset = CGPoint(x: shopsCat_TableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = maxHeaderHeight - minHeaderHeight
        let openAmount = self.locationBGHeight_constraint.constant - minHeaderHeight
        let percentage = openAmount / range
        
        locationFieldsBG_View.alpha = percentage
        locationFieldsBG_View.layoutSubviews()
    }
}

// MARK: - NavigationBar Delegate
extension GSShopsViewController: NavigationBarHomeDelegate {
    
    func rewardBtnPressed(sender: UIButton) {
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if !isGuestLogin {
            
            let scratch = GSScratchCardsViewController()
            scratch.modalPresentationStyle = .overCurrentContext
            scratch.delegate = self
            present(scratch, animated: true, completion: nil)
        } else {
            if let welcomeViewController = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                welcomeViewController.isShowingForGuestUser = true
                
                GSCustomPushPop.doCustomPush(from: self, to: welcomeViewController)
            }
            return
        }
    }
    
    func leftBarBtnPressed(sender: UIButton) {
        
        if picker != nil, picker.isDescendant(of: view) {
            return
        }
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        guard (SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String) != nil else {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.noCart, viewController: self)
            return
        }
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSCartViewController) as? GSCartViewController {
//            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedStoreCategory_id, value: categoryId ?? "")
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
    func secondRightBarBtnPressed(sender:UIButton) {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSNotificationsViewController) as? GSNotificationsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(pushVC, animated: true)
            }
        }
    }
    
    func thirdRightBarBtnPressed(sender: UIButton) {
        
        
        if let productsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSGlobalSearchViewController) as? GSGlobalSearchViewController {
            
            GSCustomPushPop.doCustomPush(from: self, to: productsVC)
        }
    }
}





