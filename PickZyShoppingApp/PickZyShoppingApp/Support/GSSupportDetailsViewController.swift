//
//  GSSupportDetailsViewController.swift
//  Shopor
//
//  Created by Ratheesh on 06/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import WebKit

class GSSupportDetailsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var top_lbl:GSBaseLabel!
//    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webView: WKWebView!
    
    var titleId = ""
    var titleText = ""
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        supportContentAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Colors For UI
    
    private func applyColors() {
        top_lbl.textColor = UIColor(hexString: defaultTheme.SupportDetailsVC_text)
//        bottomDetails_lbl.textColor = UIColor(hexString: defaultTheme.SupportDetailsVC_text)
        
        view.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
//        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.NavBarBottomLine)
        
        webView.backgroundColor = UIColor.white
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.titleText = titleText
//        top_lbl.text = titleText
    }
}

// MARK: - API Methods

extension GSSupportDetailsViewController {
    
    fileprivate func supportContentAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.support_content + titleId
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSSupportContentModel.self, from: responseData)
                    
//                    weakSelf.bottomDetails_lbl.text = responseModel.data?.content ?? ""
                    
//                    weakSelf.bottomDetails_lbl.text = (responseModel.data?.content ?? "").html2String

                    
                    weakSelf.webView.loadHTMLString("<meta name=\"viewport\" content=\"initial-scale=1.0\" />" + (responseModel.data?.content ?? ""), baseURL: nil)
                    
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
}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


// MARK:- NavigationBar Methods

extension GSSupportDetailsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
