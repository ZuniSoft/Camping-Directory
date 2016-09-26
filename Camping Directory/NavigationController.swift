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
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.tintColor = UIColor.white
    }
}
