//
//  GSFullImageCollectionCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSFullImageCollectionCell: UICollectionViewCell,UIScrollViewDelegate {

    @IBOutlet var fullImage:UIImageView!
    @IBOutlet var scroll:UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpCell()
    }

    func setUpCell() {
        scroll.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        tapGesture.numberOfTapsRequired = 2

        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 4
        scroll.addGestureRecognizer(tapGesture)
        scroll.setZoomScale(scroll.minimumZoomScale, animated: true)
    }
    
    @objc func handleDoubleTap(gestureRecognizer: UIGestureRecognizer) {
        if(self.scroll.zoomScale > self.scroll.minimumZoomScale) {
            scroll.setZoomScale(scroll.minimumZoomScale, animated: true)
        }
        else {
            scroll.setZoomScale(scroll.maximumZoomScale, animated: true)
        }
    }
    
    //MARK:- UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullImage
    }

}
