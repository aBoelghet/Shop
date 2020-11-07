//
//  GSWelcomePageViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/17/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class GSWelcomePageViewController: UIPageViewController {
    
    var arrayOfImages = [UIImage]()
    var pageControl = UIPageControl()
    var orderedViewControllers = [UIViewController]()
    
    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewInitializers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Intial Methods to load
    
    private func addFewInitializers() {
//        arrayOfImages = [#imageLiteral(resourceName: "welcomeBG_icon")]
        
        
        /*
        let arrayOfStrings = ["First life changing app to connect all kind of retail business in a single plate.",
                              "Only app that remind your product expiry/warranty date when it expires.",
                              "Exclusively shows the lowest selling price from the selected radius.",
                              "Join us with this one stop solution to buy any kind of products easily & quickly from anywhere.",
                              "Foremost unique platform to interact with your merchant directly regarding any replacement or exchange.",
                              "Shopor is designed to help your purchase simple, quick and convenient."]
        */
        
        //welcomeBG_Gif_replace
        
        let pageControllerItems_array = [GSWelcomeScreenPagesModel(infoText: "First life changing app to connect all kind of retail business in a single plate.", topImage: #imageLiteral(resourceName: "welcomeLogo_icon"), bottomImage: #imageLiteral(resourceName: "welcomeBG_one_icon"), isAnimated: false, animatedImageName: nil),
                                         GSWelcomeScreenPagesModel(infoText: "Only app that remind your product expiry/warranty date when it expires.", topImage: nil, bottomImage: #imageLiteral(resourceName: "welcomeBG_two_icon"), isAnimated: false, animatedImageName: nil),
                                         GSWelcomeScreenPagesModel(infoText: "Exclusively shows the lowest selling price from the selected radius.", topImage: nil, bottomImage: #imageLiteral(resourceName: "welcomeBG_three_icon"), isAnimated: false, animatedImageName: nil),
                                         GSWelcomeScreenPagesModel(infoText: "Join us with this one stop solution to buy any kind of products easily & quickly from anywhere.", topImage: nil, bottomImage: #imageLiteral(resourceName: "welcomeBG_four_icon"), isAnimated: false, animatedImageName: nil),
                                         GSWelcomeScreenPagesModel(infoText: "Foremost unique platform to interact with your merchant directly regarding any replacement or exchange.", topImage: nil, bottomImage: #imageLiteral(resourceName: "welcomeBG_five_icon"), isAnimated: false, animatedImageName: nil),
                                         GSWelcomeScreenPagesModel(infoText: "\(GSString.AppName) is designed to help your purchase simple, quick and convenient.", topImage: nil, bottomImage: #imageLiteral(resourceName: "welcomeBG_Gif_replace"), isAnimated: false, animatedImageName: nil)
                                         /*GSWelcomeScreenPagesModel(infoText: "\(GSString.AppName) is designed to help your purchase simple, quick and convenient.", topImage: nil, bottomImage: nil, isAnimated: true, animatedImageName: "welcomeBG_five_icon")*/]
        
        for index in 0..<pageControllerItems_array.count {
            
            guard let welcomeContentVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeContentViewController) as? GSWelcomeContentViewController else { return }
            
            let pageControllerItem = pageControllerItems_array[index]
            welcomeContentVC.pageContentItem = pageControllerItem
            orderedViewControllers.append(welcomeContentVC)
        }
        
        dataSource = self
        delegate = self
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [GSWelcomePageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.darkGray
    
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    struct GSWelcomeScreenPagesModel {
        
        let infoText:String
        let topImage: UIImage?
        let bottomImage: UIImage?
        let isAnimated:Bool
        let animatedImageName:String?
    }
}

// MARK: - UIPageController DataSource and Delegate Methods

extension GSWelcomePageViewController:UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
