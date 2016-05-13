//
//  MainTabBarController.swift
//  Qubad
//
//  Created by 小林聖哉 on 2016/05/13.
//  Copyright © 2016年 koba. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    

    override func viewDidLoad() {
         super.viewDidLoad()
        
        var viewControllers: [UIViewController] = []
        
        let firstViewController = ProfileViewController()
        firstViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), tag: 1)
        viewControllers.append(firstViewController)
        
        let secondViewController = ArticlesViewController()
        secondViewController.tabBarItem = UITabBarItem(title: "Articles", image: UIImage(named: "articles"), tag: 2)
        viewControllers.append(secondViewController)
        
        
        self.setViewControllers(viewControllers, animated: false)
        
        // なぜか0だけだと選択されないので1にしてから0に
        self.selectedIndex = 1
        self.selectedIndex = 0
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
