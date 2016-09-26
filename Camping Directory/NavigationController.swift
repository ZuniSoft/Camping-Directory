//
//  NavigationController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/25/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor(red: 53.0/255.0, green: 78.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        self.navigationBar.tintColor = UIColor.lightText
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.lightText]
    }
}
