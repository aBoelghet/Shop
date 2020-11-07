//
//  TempVC.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/27/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class TempVC: UIViewController {
    
    @IBOutlet var deliveryLocField: ACFloatingTextfield!
    @IBOutlet var fromLocField: ACFloatingTextfield!
    @IBOutlet var radiusField: ACFloatingTextfield!
    
    @IBOutlet var firstTFview: UIView!
    @IBOutlet var secondTFview: UIView!
    @IBOutlet var thirdTFview: UIView!
    @IBOutlet var navigationBarView: UIView!
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var textFieldView: UIView!
    
    let locationManger = CLLocationManager.init()
    var tfIndex:Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        let productDetails = GSProductDetailView.init(frame:view.frame)
        view.addSubview(productDetails)
        productDetails.initThisViewWithFrame(theView:self.view)
        
        addFewIntializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addFewIntializers() {
        
        let someTempArrayOfViews = [firstTFview,secondTFview,thirdTFview]
        
        for someView:UIView? in someTempArrayOfViews {
            
            someView?.layer.masksToBounds = false
            someView?.layer.shadowColor = UIColor.black.cgColor
            someView?.layer.shadowOpacity = 0.5
            someView?.layer.shadowOffset = CGSize(width: 0, height: 1)
            someView?.layer.shadowRadius = 2
        }
        
        navigationBarView.layer.masksToBounds = false
        navigationBarView.layer.shadowColor = UIColor.black.cgColor
        navigationBarView.layer.shadowOpacity = 0.5
        navigationBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        navigationBarView.layer.shadowRadius = 1
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.thirdTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.firstTFview.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.secondTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in
                
                self.tfIndex = 0
            })
        } else if sender.tag == 2 {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.thirdTFview.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.firstTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.secondTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { _ in
                self.tfIndex = 2
            })
            
        }  else {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.thirdTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.firstTFview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.secondTFview.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: { _ in
                
            })
        }
    }

}
