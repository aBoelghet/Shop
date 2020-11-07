//
//  GSLastOrderFeedbackPopupView.swift
//  Shopor
//
//  Created by Ratheesh on 08/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import StoreKit

class GSLastOrderFeedbackPopupView: NibView, UIGestureRecognizerDelegate, FloatRatingViewDelegate {
    
//    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var name_lbl:GSBaseLabel!
    @IBOutlet weak var rating_view:FloatRatingView!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var feedback_collectionView:UICollectionView!
    @IBOutlet weak var collectionViewHeight_constraint:NSLayoutConstraint!
    @IBOutlet weak var topInfo_lbl:GSBaseLabel!
    @IBOutlet weak var ratingInfo_lbl:GSBaseLabel!
    
    var feedBackMessage = ""
    
    var arrayToShow = [String]()
    var titleArray = [GSViewStoreReviewModelDataTitle]()
    var order_id = ""
    var store_id = ""
    var storeName = ""
    var selectedTitles_array = [String]()
    var loadTableData = false
    
    static let cellIdentifier = "radioCollectionCell"
    static let footerIdentifier = "footerIdentifier"
    
    let cellHeight:CGFloat = 25
    let footerHeight:CGFloat = 150
    let minimumSpacing:CGFloat = 5

    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    func configureWith(feedbackData:GSLastOrderFeedbackData) {
        
        self.order_id = feedbackData.id ?? ""
        self.store_id = feedbackData.storeID ?? ""
        self.storeName = feedbackData.shopName ?? ""
        
        name_lbl.text = storeName
        rating_view.layoutSubviews()
        
        viewStoreFeedbackAPI()
    }
    
    // MARK: - Setting up this View
    
    private func setUpThisView() {
        applyColorsForUI()
        self.addShadowEffectWith(color: UIColor.black, opacity: 0.5, shadowRadius: 3.0, shadowOffset: CGSize(width: 0, height: -3))
        
        rating_view.rating = 0
        rating_view.delegate = self
        
        feedback_collectionView.dataSource = self
        feedback_collectionView.delegate = self
        
        collectionViewHeight_constraint.constant = 0
        
        topInfo_lbl.text = "Rate your experience:"
        
        let cellNib = UINib(nibName: GSString.NibNames.GSStoreFeedbackRadioCollectionViewCell, bundle: nil)
        feedback_collectionView.register(cellNib, forCellWithReuseIdentifier: GSLastOrderFeedbackPopupView.cellIdentifier)
        
        let footerNib = UINib(nibName: GSString.NibNames.GSStoreFeedbackCollectionFooterView, bundle: nil)
        feedback_collectionView.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: GSLastOrderFeedbackPopupView.footerIdentifier)
        
        addGestures()
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture_Action))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: User defined method
    
    fileprivate func removeThisView() {
        
        if let theSuperView = self.superview {
            self.backgroundColor = UIColor.clear
            removeTheViewFrom(view: theSuperView)
        }
    }
    
    @objc private func tapGesture_Action(_ sender:UITapGestureRecognizer) {
        removeThisView()
    }
    
    // MARK: - Applying Colors
    
    private func applyColorsForUI() {
        
//        info_lbl.textColor = UIColor(hexString: defaultTheme.FeedbackPopupView_info_text)
        name_lbl.textColor = UIColor(hexString: defaultTheme.FeedbackPopupView_name_text)
    }
    
    //MARK:- Gesture Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: bg_view))! {
            return false
        }
        return true
    }
    
    // MARK: - Float Rating View Delegate Methods
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        loadTableData = true
        
        var formattedRating = rating
        if formattedRating == 0 {
            ratingView.rating = 1
            formattedRating = 1
        }
        
        let ratingInInteger = Int(formattedRating)
        arrayToShowInTableView(for: ratingInInteger)
        
        ratingInfo_lbl.text = GSCommonHelper.ratingExperienceDictionary()[ratingInInteger]
        
        if selectedTitles_array.count > 0 {
            selectedTitles_array.removeAll()
        }
        let previousCollectionViewHeight = self.collectionViewHeight_constraint.constant
        let previousViewHeight = bg_view.frame.height
        let viewHeightWithOutCollectionView = previousViewHeight - previousCollectionViewHeight

        var numberOfCells = arrayToShow.count
        
        if numberOfCells % 2 != 0 {
            numberOfCells += 1
        }
        
        let numberOfRows = numberOfCells/2
        
        let heightRequired = ((CGFloat(numberOfRows) * cellHeight) + (CGFloat(max(numberOfRows - 1, 0)) * minimumSpacing)) + footerHeight
        
        let totalHeight = heightRequired + viewHeightWithOutCollectionView
        
        feedback_collectionView.reloadData()
        
        let spaceToGive:CGFloat = 100
        
        if (totalHeight + spaceToGive) > self.frame.size.height {
            
            let subtractedHeight = self.frame.size.height - viewHeightWithOutCollectionView - spaceToGive
            self.collectionViewHeight_constraint.constant = subtractedHeight
        } else {
            self.collectionViewHeight_constraint.constant = heightRequired
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
        
        if feedback_collectionView.contentSize.height + spaceToGive > feedback_collectionView.frame.size.height {
            // Need scroll
            feedback_collectionView.isScrollEnabled = true
            
        } else {
            feedback_collectionView.isScrollEnabled = false
        }
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
    
    // MARK: - IBAction Methods
    
    @IBAction func closeAction(_ sender: UIButton) {
        removeThisView()
    }
}


// MARK: - UICollectionView Methods

extension GSLastOrderFeedbackPopupView:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if loadTableData {
            return arrayToShow.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GSLastOrderFeedbackPopupView.cellIdentifier, for: indexPath) as? GSStoreFeedbackRadioCollectionViewCell else {
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
            
            if loadTableData == false {
                return UICollectionReusableView()
            }
            
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GSLastOrderFeedbackPopupView.footerIdentifier, for: indexPath) as? GSStoreFeedbackCollectionFooterView else {
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
    
    fileprivate func validationToCallFeedbackAPI() -> Bool {
        
        let rating = rating_view.rating
        
        if rating == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterRating, viewController: GSTopViewController.topViewController())
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let reqWidth = 0.5 * (width - 20)

        return CGSize(width: reqWidth, height: cellHeight)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if loadTableData {
            return CGSize(width: collectionView.frame.size.width, height: footerHeight)
        }
        
        return CGSize.zero
    }
    
}

// MARK: - API Methods

extension GSLastOrderFeedbackPopupView {
    
    fileprivate func viewStoreFeedbackAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewShopReviewTitles
        
        let parameters = ["order_id": order_id,
                          "shop_id": store_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            

            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewStoreReviewModel.self, from: responseData)
                    
                    weakSelf.updateTheUIWithResponse(responseModel: responseModel)
                    
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    private func updateTheUIWithResponse(responseModel: GSViewStoreReviewModel) {
        
        // Check For the previous feedback
        
        guard let unwrappedData = responseModel.data else { return }
        
        if let titles_array = unwrappedData.titles {
            titleArray = titles_array
        }
        
//        if let selectedReview = unwrappedData.order?.rating {
//            loadTableData = true
//            rating_view.rating = Double(selectedReview)
//            arrayToShowInTableView(for: selectedReview)
//            if let seletedTitlesArray = unwrappedData.order?.review?.title {
//                selectedTitles_array = seletedTitlesArray
//            }
//            feedBackMessage = unwrappedData.order?.review?.message ?? ""
//        }
        
        
        name_lbl.text = unwrappedData.shop ?? ""
        feedback_collectionView.reloadData()
    }
    
    fileprivate func submitFeedbackAPI() {
        
        var urlString = ""
        var parameters = [String:AnyObject]()
        
        // Ending the editing to store feedback message
        view.endEditing(true)
        
            

                urlString = APIurl.baseURL + APIurl.subURL.trackOrderSubmitStoreFeedback
                
//            } else {
//                urlString = APIurl.baseURL + APIurl.subURL.purchaseHistorySubmitStoreFeedback
//            }
        
            parameters = ["order_id": order_id,
                          "rating": Int(rating_view.rating),
                          "title": selectedTitles_array] as [String:AnyObject]
        
        if feedBackMessage.removeEnclosedWhieteSpace() != "" {
            parameters["message"] = feedBackMessage.removeEnclosedWhieteSpace() as AnyObject
        }
        
        let topViewController = GSTopViewController.topViewController()
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }

            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSLastOrderFeedbackAPIModel.self, from: responseData)
                    
                    weakSelf.removeThisView()
                    
                    if (responseModel.ratingStat ?? true) == true {
                        weakSelf.askReview()
                    }
                    
                    
//                    if Int(self?.rating_view.rating ?? 0) > 4 {
//
//                        let isUserGivenReview = SharedPersistence.getValue(key: UserDefaultKeys.appStoreReviewShown) as? Bool ?? false
//
//                        if isUserGivenReview == true { return }
//
//                        if let lastReviewRequestEpoch = SharedPersistence.getValue(key: UserDefaultKeys.lastStoreShownEpochTime) as? Double {
//
//                            let currentEpoch = Date().timeIntervalSince1970
//
//                            let differenceTimeInHours = (currentEpoch - TimeInterval(lastReviewRequestEpoch))/3600
//
//                            if differenceTimeInHours > 72 {
//                                // Ask Review
//
//                                self?.askReview()
//                            }
//
//                        } else {
//                            // Ask Review
//                            self?.askReview()
//                        }
//
//                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: topViewController)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: topViewController)
            }
        }
    }
    
    
    private func askReview() {
        
        CustomAlert.showAlert(title: "Rate our App", message: "If you love our app, please take a moment to rate it in the App Store", alertButtonsArray: ["Rate us", "Later", "Never"], viewController: GSTopViewController.topViewController()) { btnIndex in
            
            let currentEpoch = Date().timeIntervalSince1970
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.lastStoreShownEpochTime, value: Double(currentEpoch))

            if btnIndex == 0 {
                
                guard let appUrl = URL(string: "itms-apps://itunes.apple.com/app/id1463215060") else { return }
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.appStoreReviewShown, value: true)
            }
            
            self.appRatingAPI(ratingSelection: btnIndex + 1)
        }
    }
    
    fileprivate func appRatingAPI(ratingSelection: Int) {

        let urlString = APIurl.baseURL + APIurl.subURL.appRatingAPI

        let parameters = ["respType": ratingSelection ] as [String:AnyObject]

        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { (response, error) in }
    }
}

// MARK: - UITextView Delegate Methods

extension GSLastOrderFeedbackPopupView:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        feedBackMessage = textView.text
    }
}



// MARK: - GSLastOrderFeedbackAPIModel
struct GSLastOrderFeedbackAPIModel: Codable {
    let success, ratingStat: Bool?
    let message: String?
}
