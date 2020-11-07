//
//  GSStoreFeedbackViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 30/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSStoreFeedbackViewController: GSLoggedInBaseViewController, FloatRatingViewDelegate {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
//    @IBOutlet weak var feedback_tableView: UITableView!
    @IBOutlet weak var feedback_collectionView:UICollectionView!
    @IBOutlet weak var rating_view: FloatRatingView!
    @IBOutlet weak var nameKey_lbl:GSBaseLabel!
    @IBOutlet weak var dateKey_lbl:GSBaseLabel!
    @IBOutlet weak var nameValue_lbl: GSBaseLabel!
    @IBOutlet weak var dateValue_lbl: GSBaseLabel!
    @IBOutlet weak var ratingInfo_lbl:GSBaseLabel!
    
    static let cellIdentifier = "radioCollectionCell"
    static let footerIdentifier = "footerIdentifier"
    
    var isProductFeedBack = false
    var isFromTrackOrder = false
    var isDeliveredProducts = false
    
    var feedBackMessage = ""

    var arrayToShow = [String]()
    var titleArray = [GSViewStoreReviewModelDataTitle]()
    var order_id = ""
    var store_id = ""
    var category_id = ""
    var product_id = ""
    var selectedTitles_array = [String]()
    
    var loadTableData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        
        if isProductFeedBack {
            viewProductFeedbackAPI()
        } else {
            viewStoreFeedbackAPI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Configuring with data
    
    func configureForStoreFeedBack(orderId:String, storeId:String, isFromTrackOrder:Bool, isDeliveredProducts:Bool) {
        
        self.order_id = orderId
        self.store_id = storeId
        isProductFeedBack = false
        self.isFromTrackOrder = isFromTrackOrder
        self.isDeliveredProducts = isDeliveredProducts
    }
    
    func configureForProductFeedBack(categoryId:String, orderId:String,productId:String, isFromTrackOrder:Bool) {
        self.category_id = categoryId
        self.order_id = orderId
        self.product_id = productId
        self.isProductFeedBack = true
        self.isFromTrackOrder = isFromTrackOrder
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        view.backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_view_BG)
        nameKey_lbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_storeName_text)
        dateKey_lbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_deliveryDate_text)
        
        nameValue_lbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_storeName_text)
        dateValue_lbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_deliveryDate_text)
    }
    
    //MARK:- User defined methods
    
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        rating_view.rating = 0
        rating_view.delegate = self
        navigationBar_view.leftBarImage.image = #imageLiteral(resourceName: "Back_arrow")
        navigationBar_view.leftBarBtn.isHidden = false
        
        navigationBar_view.rightBarImage.image = nil
        navigationBar_view.rightBtnTitle = ""
        navigationBar_view.rightBarBtn.isHidden = true
        
        feedback_collectionView.delegate = self
        feedback_collectionView.dataSource = self
        feedback_collectionView.backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_BG)
        
        let cellNib = UINib(nibName: GSString.NibNames.GSStoreFeedbackRadioCollectionViewCell, bundle: nil)
        feedback_collectionView.register(cellNib, forCellWithReuseIdentifier: GSStoreFeedbackViewController.cellIdentifier)
        
        let footerNib = UINib(nibName: GSString.NibNames.GSStoreFeedbackCollectionFooterView, bundle: nil)
        feedback_collectionView.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: GSStoreFeedbackViewController.footerIdentifier)
        
//        if isFromTrackOrder {
//            navigationBar_view.leftBarImage.image = nil
//            navigationBar_view.leftBarBtn.isHidden = true
//        }
        
        if isDeliveredProducts {
            navigationBar_view.leftBarImage.image = nil
            navigationBar_view.leftBarBtn.isHidden = true
            
            navigationBar_view.rightBtnTitle = "Cancel"
            navigationBar_view.rightBarBtn.isHidden = false
        }
    }
    
    // MARK: - Float Rating View Delegate Methods
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        loadTableData = true
        
        let ratingInInteger = Int(rating)
        arrayToShowInTableView(for: ratingInInteger)
        
        if arrayToShow.count > 0 {
            ratingInfo_lbl.text = GSCommonHelper.ratingExperienceDictionary()[ratingInInteger]
        }
        
        if selectedTitles_array.count > 0 {
            selectedTitles_array.removeAll()
        }
        feedback_collectionView.reloadData()
    }
    
    fileprivate func popToTrackOrderOrPurchaseHistoryVC() {
        
        if isFromTrackOrder {
            
            for vc in (self.navigationController?.viewControllers)!.reversed() {
                if vc is GSTrackOrderListViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
        } else {
            
            if isProductFeedBack {
                navigationController?.popViewController(animated: true)
                return
            }
            
            for vc in (self.navigationController?.viewControllers)!.reversed() {
                if vc is GSPurchaseHistoryViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    fileprivate func validationToCallFeedbackAPI() -> Bool {

        let rating = rating_view.rating
        
        if rating == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterRating, viewController: self)
            return false
        }
        
//        else if selectedTitles_array.count == 0 {
//            CustomAlert.showAlert(title: GSString.AppName, message: "Please select the check box", viewController: self)
//            return false
//        } else if feedBackMessage.removeEnclosedWhieteSpace().count == 0 {
//            CustomAlert.showAlert(title: GSString.AppName, message: "Please write feedback", viewController: self)
//            return false
//        }
        return true
    }
}

// MARK: - UITextView Delegate Methods

extension GSStoreFeedbackViewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        feedBackMessage = textView.text
    }
}


// MARK: - UICollectionView Methods

extension GSStoreFeedbackViewController:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if loadTableData {
            return arrayToShow.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSStoreFeedbackViewController.cellIdentifier, for: indexPath) as? GSStoreFeedbackRadioCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.applyColors()
        
        let itemAtIndex = arrayToShow[indexPath.row]
        
        let filteredText = itemAtIndex.replacingOccurrences(of: "_", with: " ")
        let formattedText = filteredText.capitalized(with: Locale.current)
        cell.feedBackoptionLbl.text = formattedText
        cell.feedBackoptionLbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_text)
        
        cell.radioImage.image = #imageLiteral(resourceName: "Uncheck_icon")
        
        if selectedTitles_array.contains(itemAtIndex) {
            cell.radioImage.image = #imageLiteral(resourceName: "Check_icon")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row < arrayToShow.count {
            
            let itemAtIndex = arrayToShow[indexPath.row]
            if selectedTitles_array.contains(itemAtIndex) {
                if let indexOfSelected = selectedTitles_array.index(of: itemAtIndex) {
                    selectedTitles_array.remove(at: indexOfSelected)
                }
            } else {
                selectedTitles_array.append(itemAtIndex)
            }
            feedback_collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionFooter:
            
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GSStoreFeedbackViewController.footerIdentifier, for: indexPath) as? GSStoreFeedbackCollectionFooterView else {
                return UICollectionReusableView()
            }
            footerView.appleColors()
            footerView.textView.text = feedBackMessage
            footerView.textView.delegate = self
            footerView.submit_btn.addTarget(self, action: #selector(commentCell_submit_btnAction(_:)), for: .touchUpInside)
            footerView.submit_btn.setTitleColor(UIColor(hexString: defaultTheme.storeFeedBack_cell_text), for: .normal)
            return footerView
            
        default:
            return UICollectionReusableView()
        }
    }
    
    
    @objc func commentCell_submit_btnAction(_ sender:UIButton) {
        
        if validationToCallFeedbackAPI() {
            submitFeedbackAPI()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let reqWidth = 0.5 * (width - 20)
        
        let height:CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 30 : 20
        
        return CGSize(width: reqWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 150)
    }
    
}

// MARK: - API Methods

extension GSStoreFeedbackViewController {
    
    fileprivate func viewStoreFeedbackAPI() {
        
        let urlString = isProductFeedBack ? APIurl.baseURL + APIurl.subURL.viewProductReviewTitles : APIurl.baseURL + APIurl.subURL.viewShopReviewTitles
        
        let parameters = ["order_id": order_id,
                          "shop_id": store_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if weakSelf.isVisible == false {
                return
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewStoreReviewModel.self, from: responseData)
                    
                    self?.updateTheUIWithResponse(responseModel: responseModel)
                    
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
    
    private func updateTheUIWithResponse(responseModel: GSViewStoreReviewModel) {
        
        // Check For the previous feedback
        
        guard let unwrappedData = responseModel.data else { return }
        
        if let titles_array = unwrappedData.titles {
            titleArray = titles_array
        }
        
        if let selectedReview = unwrappedData.order?.rating {
            loadTableData = true
            rating_view.rating = Double(selectedReview)
            
            ratingInfo_lbl.text = GSCommonHelper.ratingExperienceDictionary()[selectedReview]
            
            arrayToShowInTableView(for: selectedReview)
            if let seletedTitlesArray = unwrappedData.order?.review?.title {
                selectedTitles_array = seletedTitlesArray
            }
            feedBackMessage = unwrappedData.order?.review?.message ?? ""
        }
        
        dateKey_lbl.text = "Delivery Date: "
        
        navigationBar_view.titleText = "Store Feedback"
        nameKey_lbl.text = "Store Name: "
        nameValue_lbl.text = unwrappedData.shop ?? ""
        dateValue_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: unwrappedData.order?.deliveredAt, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        feedback_collectionView.reloadData()
    }
    
    fileprivate func arrayToShowInTableView(for review:Int) {
        
        if arrayToShow.count > 0 {
            arrayToShow.removeAll()
            feedback_collectionView.reloadData()
        }
        
        for titleItem in titleArray {
            if titleItem.rating == review {
                arrayToShow = titleItem.titles ?? [String]()
                break
            }
        }
    }
    
    fileprivate func submitFeedbackAPI() {
        
        var urlString = ""
        var parameters = [String:AnyObject]()
        
        // Ending the editing to store feedback message
        view.endEditing(true)
        
        if isProductFeedBack {
            
            if isFromTrackOrder {
                urlString = APIurl.baseURL + APIurl.subURL.trackOrderSubmitProductFeedback
            } else {
                urlString = APIurl.baseURL + APIurl.subURL.purchaseHistorySubmitProductFeedback
            }
            
            parameters = ["category_id": category_id,
                          "order_id": order_id,
                          "product_id": product_id,
                          "rating": Int(rating_view.rating),
                          "title": selectedTitles_array] as [String:AnyObject]
            
        } else {
            
            if isFromTrackOrder {
                urlString = APIurl.baseURL + APIurl.subURL.trackOrderSubmitStoreFeedback
                
            } else {
                urlString = APIurl.baseURL + APIurl.subURL.purchaseHistorySubmitStoreFeedback
            }
            
            parameters = ["order_id": order_id,
                          "rating": Int(rating_view.rating),
                          "title": selectedTitles_array] as [String:AnyObject]
        }
        
        if feedBackMessage.removeEnclosedWhieteSpace() != "" {
            parameters["message"] = feedBackMessage.removeEnclosedWhieteSpace() as AnyObject
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if weakSelf.isVisible == false {
                return
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { btnIndex in
                        
                        if responseModel.success == true {
                            weakSelf.popToTrackOrderOrPurchaseHistoryVC()
                        }
                    })
                    
                } catch {
                    print(error)
                    weakSelf.manageFailureResponseForTrackOrderFeedback(errorMessage: error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.manageFailureResponseForTrackOrderFeedback(errorMessage: error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    private func manageFailureResponseForTrackOrderFeedback(errorMessage: String) {
        
        if isFromTrackOrder {
            CustomAlert.showAlert(title: GSString.AppName, message: errorMessage, alertButtonsArray: ["Skip", "Retry"], viewController: self, completion: { btnIndex in
                
                if btnIndex == 0 {
                    self.popToTrackOrderOrPurchaseHistoryVC()
                }
            })
        } else {
            CustomAlert.showAlert(title: GSString.AppName, message: errorMessage, viewController: self)
        }
    }
    
    fileprivate func viewProductFeedbackAPI() {
        //GSViewProductReviewModel
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewProductReviewTitles
        
        let parameters = ["category_id": category_id,
                          "order_id": order_id,
                          "product_id": product_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if weakSelf.isVisible == false {
                return
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewProductReviewModel.self, from: responseData)
                    weakSelf.updateTheUIWithProductFeedbackResponse(responseModel: responseModel)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
    
    private func updateTheUIWithProductFeedbackResponse(responseModel: GSViewProductReviewModel) {
        
        // Check For the previous feedback
        
        guard let unwrappedData = responseModel.data else { return }
        
        if let titles_array = unwrappedData.titles {
            titleArray = titles_array
        }
        
        if let selectedReview = unwrappedData.product?.rating {
            loadTableData = true
            rating_view.rating = Double(selectedReview)
            arrayToShowInTableView(for: selectedReview)
            if let seletedTitlesArray = unwrappedData.product?.review?.title {
                selectedTitles_array = seletedTitlesArray
                
                if titleArray.count > 0 {
                    ratingInfo_lbl.text = GSCommonHelper.ratingExperienceDictionary()[selectedReview]
                }
            }
            feedBackMessage = unwrappedData.product?.review?.message ?? ""
        }
        
        dateKey_lbl.text = "Delivery Date: "
        
        navigationBar_view.titleText = "Product Feedback"
        nameKey_lbl.text = "Product Name: "
        nameValue_lbl.text = unwrappedData.product?.name ?? ""
        dateValue_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: unwrappedData.order?.deliveredAt, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        feedback_collectionView.reloadData()
    }
}


// MARK: NavigationBar Methods

extension GSStoreFeedbackViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    func rightBarBtnPressed(sender:UIButton) {
        
        popToTrackOrderOrPurchaseHistoryVC()
    }
}

// MARK: - New models

// MARK: - View Store Review Model

struct GSViewStoreReviewModel: Codable {
    let success: Bool?
    let data: GSViewStoreReviewModelData?
}

struct GSViewStoreReviewModelData: Codable {
    let shop: String?
    let order: GSViewStoreReviewModelDataOrder?
    let titles: [GSViewStoreReviewModelDataTitle]?
}

struct GSViewStoreReviewModelDataOrder: Codable {
    let deliveredAt: String?
    let rating: Int?
    let review: GSViewStoreReviewModelDataOrderReview?
    
    enum CodingKeys: String, CodingKey {
        case deliveredAt = "delivered_at"
        case rating, review
    }
}

struct GSViewStoreReviewModelDataOrderReview: Codable {
    let title: [String]?
    let message: String?
}

struct GSViewStoreReviewModelDataTitle: Codable {
    let rating: Int?
    let titles: [String]?
}

// MARK: - View Product Review Model

struct GSViewProductReviewModel: Codable {
    let success: Bool?
    let data: GSViewProductReviewData?
}

struct GSViewProductReviewData: Codable {
    let product: GSViewProductReviewDataProduct?
    let order: GSViewProductReviewDataOrder?
    let titles: [GSViewStoreReviewModelDataTitle]?
}

struct GSViewProductReviewDataOrder: Codable {
    let deliveredAt: String?
    
    enum CodingKeys: String, CodingKey {
        case deliveredAt = "delivered_at"
    }
}

struct GSViewProductReviewDataProduct: Codable {
    let id, name: String?
    let rating: Int?
    let review: GSViewProductReviewDataProductReview?
    let at: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, rating, review, at
    }
}

struct GSViewProductReviewDataProductReview: Codable {
    let title: [String]?
    let message: String?
}


