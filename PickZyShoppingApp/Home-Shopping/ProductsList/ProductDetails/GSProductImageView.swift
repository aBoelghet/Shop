//
//  GSProductImageView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/1/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSProductImageView: NibView {
    
    @IBOutlet weak var imageCollection:UICollectionView!
    @IBOutlet weak var pageControl:DAPageControlView!
    @IBOutlet weak var bg_topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bg_bottomConstraint: NSLayoutConstraint!
    
    var imagesArray : [Any]? = nil
    var imageIndex =  Int()
    var currentPage = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageIndex  = 0
        someSetUps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        someSetUps()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Public Methods
    public func refreshPageControlAndOffset() {
        UIView.animate(withDuration: 0.5) {
            self.imageCollection.contentOffset = CGPoint(x: CGFloat(self.pageControl.currentPage) * self.imageCollection.frame.size.width, y: 0)
        }
    }
    
    // MARK: User defined methods
    private func someSetUps() {
        
        let nib = UINib.init(nibName: GSString.NibNames.GSFullImageCollectionCell, bundle: nil)
        imageCollection.register(nib, forCellWithReuseIdentifier: GSString.CellIdentifier.ProductImageView_image_collectionCell)
        imageCollection.delegate = self
        imageCollection.dataSource = self
        configurePageControlForProducts()
    }
    
    func initThisViewWithFrame(theView:UIView) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: theView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: theView, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: theView, attribute: .top, multiplier: 1, constant: GSTopViewController.topViewController().view.safeAreaInsets.top)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: theView, attribute: .bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
 
    func currentIndexPath() -> IndexPath {
        
        let visibleRect = CGRect(origin: imageCollection.contentOffset, size: imageCollection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let indexPath = imageCollection.indexPathForItem(at: visiblePoint)
        return indexPath!
    }
    
    func getCurrentPage()-> Int {
        
        let offset = imageCollection.contentOffset.x
        let pageWidth = imageCollection.frame.size.width
        let pageNumber = offset/pageWidth
        return Int(pageNumber)
    }
    
    //MARK: Page Control methods
    func configurePageControlForProducts() {
        
        pageControl.delegate = self
        let imagesCount = imagesArray?.count ?? 0
        pageControl.numberOfPages = UInt(imagesCount)
        pageControl.currentPage = UInt(bitPattern: imageIndex)
        pageControl.selectedColor = UIColor(hexString: defaultTheme.pageControl_selection)
        pageControl.backgroundColor = UIColor(hexString: defaultTheme.pageControl_BG)
    }
    
    func updatePageControl(_ offsetX:CGFloat) {
        pageControl.update(forScrollContentOffset: offsetX, pageSize: imageCollection.frame.size.width)
        imageCollection.contentOffset = CGPoint.init(x: offsetX, y: 0)
    }
    
    //MARK: IBAction methods
    @IBAction func nextImage(_ sender: UIButton) {
        
        let pageNumber = getCurrentPage()
        
        if pageNumber < (imagesArray?.count ?? 0) - 1 {
            
            imageCollection.contentOffset = CGPoint.init(x: imageCollection.contentOffset.x + imageCollection.frame.size.width, y: 0)
        }
    }
    
    @IBAction func previousImage(_ sender: UIButton) {
        
        let pageNumber = getCurrentPage()
        
        if pageNumber > 0 {
            imageCollection.contentOffset = CGPoint.init(x: imageCollection.contentOffset.x - imageCollection.frame.size.width, y: 0)
        }
    }
    
    @IBAction func closeFullImageView(_ sender: UIButton) {
//        self.removeTheViewFrom(view: self.superview!)
        closeThisView()
    }
    
    func showTheViewOn (_ parenView:UIView) {
        
        parenView.addSubview(self)
        
        initThisViewWithConstraints(parenView)
        
        let heightOfParent = parenView.frame.size.height
        bg_topConstraint.constant = heightOfParent
        bg_bottomConstraint.constant = -heightOfParent
        layoutIfNeeded()
        self.bg_topConstraint.constant = 0
        self.bg_bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
//            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
    
    private func closeThisView() {
        
        let height = frame.size.height
        bg_topConstraint.constant = 0
        bg_bottomConstraint.constant = 0
        layoutIfNeeded()
        self.bg_topConstraint.constant = height
        bg_bottomConstraint.constant = -height
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.clear
            self.layoutIfNeeded()
            
        },completion: { _ in
            self.removeFromSuperview()
        })
    }
}

extension GSProductImageView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imagesArray == nil {
            return 0;
        }
        // Crash noted
        return (imagesArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = GSString.CellIdentifier.ProductImageView_image_collectionCell
        
        guard let cell = imageCollection.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? GSFullImageCollectionCell else {
            return UICollectionViewCell()
        }
        let imageName = imagesArray![indexPath.row] as? [String: Any]
        let imageUrl = APIurl.baseURL + APIurl.subURL.viewProductImage + (imageName!["name"] as! String)
        let imgHeight = "&height=" + "\(cell.frame.size.height)"
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return UICollectionViewCell()
        }
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        cell.fullImage.sd_setImage(with: URL(string: imageUrl + imgHeight) , placeholderImage: #imageLiteral(resourceName: "Pickzy_logo"), completed: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: imageCollection.frame.size.width - 10, height: imageCollection.frame.size.height - 10)
    }
}

extension GSProductImageView:UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageCollection.collectionViewLayout.invalidateLayout()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.size.width
        
        let pageNumber = offset/pageWidth
        
        pageControl.currentPage = UInt(pageNumber)
        
        if currentPage != Int(pageNumber) {
            currentPage = Int(pageNumber)
            
            let indexPath = IndexPath.init(row: currentPage, section: 0)
            
            guard let cell = imageCollection.cellForItem(at: indexPath) as? GSFullImageCollectionCell else {
                return
            }
            cell.scroll.setZoomScale(cell.scroll.minimumZoomScale, animated: true)
        }
    }
}

extension GSProductImageView:DAPageControlViewDelegate {
    
    func pageControlViewDidChangeCurrentPage(_ pageControlView: DAPageControlView!) {
    
        let contentOffsetX = CGFloat(pageControlView.currentPage) * imageCollection.frame.size.width
        updatePageControl(contentOffsetX)
    }
}

