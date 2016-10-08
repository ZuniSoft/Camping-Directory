//
//  SearchResultCell.swift
//  Camping Directory
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
//  Created by Keith Davis on 9/29/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var FacilityName: UILabel!
    @IBOutlet weak var powerIcon: UIImageView!
    @IBOutlet weak var waterIcon: UIImageView!
    @IBOutlet weak var sewerIcon: UIImageView!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var sewerLabel: UILabel!
    @IBOutlet weak var FacilityId: UILabel!
    @IBOutlet weak var Icon: UIImageView!
}
