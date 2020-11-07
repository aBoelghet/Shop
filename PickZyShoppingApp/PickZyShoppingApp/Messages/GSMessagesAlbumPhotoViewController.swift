//
//  GSMessagesAlbumPhotoViewController.swift
//  Shopor
//
//  Created by Ratheesh on 16/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSMessagesAlbumPhotoViewController: GSLoggedInBaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var preview_imgView:UIImageView!
    @IBOutlet var zoom_scrollView:UIScrollView!
    
    var imageLinkToClearCache = ""
    var imageLink = ""

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        preview_imgView.image = nil
        
        if imageLink == "" { return }
        let imgHeight : String = "&height=" + "\(max(view.frame.size.height, view.frame.size.width))"
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        imageLinkToClearCache = APIurl.baseURL + APIurl.subURL.message_viewAlbum + imageLink + imgHeight
        preview_imgView.sd_setImage(with: URL(string: imageLinkToClearCache) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        zoom_scrollView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        tapGesture.numberOfTapsRequired = 2
        
        zoom_scrollView.minimumZoomScale = 1
        zoom_scrollView.maximumZoomScale = 4
        zoom_scrollView.addGestureRecognizer(tapGesture)
        zoom_scrollView.setZoomScale(zoom_scrollView.minimumZoomScale, animated: true)
    }
    
    @objc func handleDoubleTap(gestureRecognizer: UIGestureRecognizer) {
        if(self.zoom_scrollView.zoomScale > self.zoom_scrollView.minimumZoomScale) {
            zoom_scrollView.setZoomScale(zoom_scrollView.minimumZoomScale, animated: true)
        }
        else {
            zoom_scrollView.setZoomScale(zoom_scrollView.maximumZoomScale, animated: true)
        }
    }
    
    //MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return preview_imgView
    }

}

// MARK:- NavigationBar Methods

extension GSMessagesAlbumPhotoViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
        SDImageCache.shared().removeImage(forKey: imageLinkToClearCache, fromDisk: true, withCompletion: nil)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
