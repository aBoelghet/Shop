//
//  GSProductDescriptionView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 16/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDescriptionView: NibView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    
    var imageArr = [UIImage]()
    var imageIndex = Int()
    var descriptionText = [String]()
    var isPresented = false
    
    
    @IBOutlet weak var tbleProductDetail: UITableView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var buttonStackView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leftArrBtn: UIButton!
    @IBOutlet weak var rightArrBtn: UIButton!
    @IBOutlet weak var topLevelViewHeghtConstarints: NSLayoutConstraint!
    
    @IBOutlet weak var close_btn:UIButton!
    @IBOutlet weak var addToCart_btn:UIButton!
    @IBOutlet weak var productName_lbl:GSBaseLabel!
    
    //MARK: - Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cellNib = UINib.init(nibName: "GSProductDesTableViewCell", bundle: nil)
        tbleProductDetail.register(cellNib, forCellReuseIdentifier: "ProductDesCell")
        self.tbleProductDetail.tableFooterView = UIView.init(frame: CGRect.zero)
        
        imageArr = [UIImage(named:"img3.png"), UIImage(named:"img4.png"), UIImage(named:"img5.png"), UIImage(named:"img7.png")] as! [UIImage]
        descriptionText = ["Weight", "Price", "Qty"]
        
        imageIndex = 0
        let imageStr = imageArr[imageIndex]
        productImage.image = imageStr
        
        pageControl.numberOfPages = imageArr.count
        pageControl.currentPage = imageIndex
        
        //        self.leftArrBtn.isHidden = true
        self.addSwipeGesture()
        tbleProductDetail.tableFooterView = UIView()
        
        applyColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        //        topLevelViewHeghtConstarints.constant = buttonStackView.frame.height + buttonStackView.frame.origin.y + 0
        
    }
    
    
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        productName_lbl.textColor = UIColor(hexString: defaultTheme.productDescriptionView_labels)
        productName_lbl.backgroundColor = UIColor(hexString: defaultTheme.productDescriptionView_productName_BG)
        
        close_btn.setTitleColor(UIColor(hexString: defaultTheme.productDescriptionView_closeBtn_title), for: .normal)
        close_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescriptionView_closeBtn_BG)
        
        addToCart_btn.setTitleColor(UIColor(hexString: defaultTheme.productDescriptionView_addCartBtn_title), for: .normal)
        addToCart_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescriptionView_addCartBtn_BG)
    }
    
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDesCell") as! GSProductDetailsTableViewCell
        
        if indexPath.row == 2 {
            cell.plusMinusView.isHidden = false
            cell.minus_btn.tag = indexPath.row
            cell.minus_btn.addTarget(self, action: #selector(cell_minusAction(_:)), for: .touchUpInside)
            cell.plus_btn.tag = indexPath.row
            cell.plus_btn.addTarget(self, action: #selector(cell_plusAction(_:)), for: .touchUpInside)
            cell.detailValue_lbl.isHidden = true
            cell.quantity_lbl.layer.borderColor = UIColor.black.cgColor
            cell.quantity_lbl.layer.borderWidth = 1.0
        }
        else{
            cell.plusMinusView.isHidden = true
            cell.detailValue_lbl.isHidden = false
        }
        cell.detailKey_lbl.text = descriptionText[indexPath.row]
        cell.detailKey_lbl.textColor = UIColor(hexString: defaultTheme.productDescriptionView_cell_text)
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 38
        //        return 0.06 * self.view.frame.size.height
    }
    
    
    //MARK: - Cell Action methods
    
    @objc func cell_plusAction (_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = tbleProductDetail.cellForRow(at: indexPath) as? GSProductDetailsTableViewCell else {
            return
        }
        if var quantity = Int(cell.quantity_lbl.text!) {
            quantity += 1
            cell.quantity_lbl.text = "\(quantity)"
        }
    }
    @objc func cell_minusAction (_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = tbleProductDetail.cellForRow(at: indexPath) as? GSProductDetailsTableViewCell else {
            return
        }
        if var quantity = Int(cell.quantity_lbl.text!) {
            if quantity > 0 {
                quantity -= 1
            }
            cell.quantity_lbl.text = "\(quantity)"
        }
        
    }
    
    //MARK: - ButtonAction
    
    @IBAction func closeProductDetails(_ sender: GSBaseButton) {
        
        isPresented = false
        self.removeTheViewFrom(view: self)
    }
    
    @IBAction func Action_RightArrowBtn(_ sender: UIButton) {
        
        self.scrollImageRightSide()
    }
    @IBAction func Action_LeftArrowBtn(_ sender: UIButton) {
        
        self.scrollImageLeftSide()
    }
    @IBAction func Action_ProductZoomView(_ sender: UIButton) {
        let zoomView = GSProductImageView()
        
        let topViewController = GSTopViewController.topViewController()
        zoomView.showTheViewFromBottom(on: topViewController.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {})
    }
    
    
    //MARK: - SwipeGestureMethods
    
    func addSwipeGesture() -> Void {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeView.addGestureRecognizer(swipeLeft)
        
    }
    
    
    @objc func respondToSwipeGesture(gesture:UIGestureRecognizer) -> Void {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                self.scrollImageLeftSide()
            case UISwipeGestureRecognizerDirection.left:
                self.scrollImageRightSide()
                
            default:
                break
            }
        }
        
    }
    
    //MARK: - ChangeImageBasedOn Right And Left side
    
    func scrollImageRightSide() -> Void {
        
        if imageIndex < imageArr.count - 1  {
            imageIndex += 1
            self.pageControl.currentPage = self.imageIndex
            //            self.showBtnArrow(isHide: false, isUnHide: false)
            
            UIView.transition(with: self.productImage, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                
                self.productImage.image = self.imageArr[self.imageIndex]
                if self.imageIndex+1 == self.imageArr.count {
                    //                    self.showBtnArrow(isHide: false, isUnHide: true)
                    
                }
                
            }, completion: nil)
        }
        
    }
    func scrollImageLeftSide() -> Void {
        
        if imageIndex > 0 {
            imageIndex -= 1
            self.pageControl.currentPage = self.imageIndex
            
            UIView.transition(with: self.productImage, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                
                self.productImage.image = self.imageArr[self.imageIndex]
                if self.imageIndex == 0 {
                    //                    self.showBtnArrow(isHide: true, isUnHide: false)
                    
                }
                
            }, completion: nil)
        }
        
        
    }
    func showBtnArrow(isHide:Bool,isUnHide:Bool) -> Void {
        
        self.leftArrBtn.isHidden = isHide
        self.rightArrBtn.isHidden = isUnHide
    }
}
