//
//  GSWelcomeContentViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/17/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class GSWelcomeContentViewController: GSBaseViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var bottom_imgView: UIImageView!
    
    var pageIndex: Int = 0
    
    var pageContentItem:GSWelcomePageViewController.GSWelcomeScreenPagesModel!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageContentView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setting up page content view
    
    private func setupPageContentView() {
        
        info_lbl.textColor = UIColor(hexString: "3C3C3C")
        
        if pageContentItem.topImage == nil {
            mainImageView.isHidden = true
        }
        
        if pageContentItem.bottomImage == nil && pageContentItem.animatedImageName == nil {
            bottom_imgView.isHidden = true
        }
        
        if pageContentItem.isAnimated, let imageName = pageContentItem.animatedImageName {
            
            let image = UIImage.gifImageWithName(imageName)
            bottom_imgView.image = image
            
        } else {
            bottom_imgView.image = pageContentItem.bottomImage
        }
        
        mainImageView.image = pageContentItem.topImage
        info_lbl.text = pageContentItem.infoText
    }
}
