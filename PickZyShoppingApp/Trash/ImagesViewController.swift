//
//  ImagesViewController.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 17/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var img4: UIImageView!
    
    @IBOutlet weak var img5: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img1.sd_setImage(with: URL(string: "https://s3.us-east-2.amazonaws.com/shoporapp/category/2955953909186.jpeg") , placeholderImage: #imageLiteral(resourceName: "placeholder"), completed: nil)
        
         img2.sd_setImage(with: URL(string: "https://s3.us-east-2.amazonaws.com/shoporapp/category/3834034036207.jpeg") , placeholderImage: #imageLiteral(resourceName: "placeholder"), completed: nil)
        
         img3.sd_setImage(with: URL(string: "https://s3.us-east-2.amazonaws.com/shoporapp/category/4626500246689.jpeg") , placeholderImage: #imageLiteral(resourceName: "placeholder"), completed: nil)
        
         img4.sd_setImage(with: URL(string: "https://s3.us-east-2.amazonaws.com/shoporapp/category/5185905543753.png") , placeholderImage: #imageLiteral(resourceName: "placeholder"), completed: nil)
        
         img5.sd_setImage(with: URL(string: "https://s3.us-east-2.amazonaws.com/shoporapp/category/Desert.jpg") , placeholderImage: #imageLiteral(resourceName: "placeholder"), completed: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
