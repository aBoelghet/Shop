//
//  GSProductReportViewController.swift
//  Shopor
//
//  Created by Ratheesh on 07/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductReportViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    @IBOutlet weak var reviews_tableView:UITableView!
    @IBOutlet weak var productName_lbl:GSBaseLabel!
    @IBOutlet weak var productNameBG_view:UIView!
    @IBOutlet weak var bottomLine_view:UIView!
    
    var selectedIndex = -1
    var message_text = ""
    var reviewTypes_array = [String]()
    var product_name = ""
    var productId = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        applyColors()
        addFewIntializers()
        viewReportTypesAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuring with data
    
    func configureReportViewWith(productName:String, product_id:String) {
        self.product_name = productName
        self.productId = product_id
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        productName_lbl.textColor = UIColor(hexString: defaultTheme.ProductReportsVC_productName)
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.ProductReportsVC_bottomLine)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.rightBarBtn.isHidden = true
        navigationBar_view.rightBarImage.isHidden = true
        
        reviews_tableView.dataSource = self
        reviews_tableView.delegate = self
        
        productName_lbl.text = product_name
    }
}

// MARK: - UITableView Methods

extension GSProductReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if reviewTypes_array.count > 0 {
            return reviewTypes_array.count + 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == reviewTypes_array.count {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.productReportTextViewTableCell) as? GSProductReportTextViewTableViewCell else {
                return UITableViewCell()
            }
            cell.report_txtView.delegate = self
            return cell
            
        } else {
            
            let identifier = GSString.CellIdentifier.StoreFeedbackVC_option_tableCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSStoreFeedBackTableViewCell else {
                return UITableViewCell()
            }
            
            cell.feedBackoptionLbl.text = reviewTypes_array[indexPath.row]
            cell.feedBackoptionLbl.textColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_text)
            cell.backgroundColor = UIColor(hexString: defaultTheme.ProductReportsVC_tableBG)

            if selectedIndex != indexPath.row {
                cell.radioImage.image = #imageLiteral(resourceName: "Radio_off")

            } else {
                cell.radioImage.image = #imageLiteral(resourceName: "Radio_on")
            }
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < reviewTypes_array.count {
            selectedIndex = indexPath.row
            tableView.reloadData()
        }
    }
}

// MARK: - UITextView Delegate Methods

extension GSProductReportViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        message_text = textView.text
    }
}

// MARK: - API Methods

extension GSProductReportViewController {
    
    fileprivate func viewReportTypesAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.productViewReportTypes
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSProductViewReportTypesModel.self, from: responseData)
                    
                    if let reviewTypes = responseModel.data?.type {
                        weakSelf.reviewTypes_array = reviewTypes
                        weakSelf.navigationBar_view.rightBarImage.isHidden = false
                        weakSelf.navigationBar_view.rightBarBtn.isHidden = false
                        weakSelf.reviews_tableView.reloadData()
                    }
                    
                } catch {
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
    
    fileprivate func submitReportAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.reportProduct
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        var selectedType = ""
        
        if selectedIndex < reviewTypes_array.count {
            selectedType = reviewTypes_array[selectedIndex]
        }
        
        var messageValue = "NA"
        if message_text != "" {
            messageValue = message_text
        }
        
        let parameters = ["_id": storeCategory_id,
                          "product": productId,
                          "type": selectedType,
                          "message": messageValue] as [String:AnyObject]

        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
           
            guard let weakSelf = self else { return }

            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        GSCustomPushPop.doCustomPop(from: weakSelf)
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    }
                    
                } catch {
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
}

// MARK: - Navigation Bar View Delegate Methods

extension GSProductReportViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        GSCustomPushPop.doCustomPop(from: self)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        view.endEditing(true)
        
        if selectedIndex != -1 {
            submitReportAPI()
        } else {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.reportViewValidation, viewController: self)
        }
    }
}


// MARK: - Model Class

struct GSProductViewReportTypesModel: Codable {
    let success: Bool?
    let data: GSProductViewReportTypesData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSProductViewReportTypesData: Codable {
    let type: [String]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = values.decodeSafely(.type)
    }
}
