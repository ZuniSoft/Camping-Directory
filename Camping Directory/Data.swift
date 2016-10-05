//
//  Data.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/29/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import Foundation
import UIKit

class Data {
    struct SearchResult {
        var contractId = String();
        var facilityName = String();
        var facilityId = String();
        var latitude = String();
        var longitude = String();
    }
    
    struct AmenityResult {
        var amenityDescription = String();
        var amenityLocation = String();
        var amenityIcon = UIImage();
    }
}
