//
//  DetailController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/28/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class DetailController: UIViewController {
    // Segue data
    var sequeData : Data.SearchResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FACILITY ID:" + (sequeData?.facilityId)!)
    }
}
