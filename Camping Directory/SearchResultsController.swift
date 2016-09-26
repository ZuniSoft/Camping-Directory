//
//  SearchResultsViewController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/18/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class SearchResultsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
   
    var sequeUrl : String?
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchUrl = sequeUrl
        
        var cnt : Int = 0
        
        loadData()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
        Alamofire.request(
            Constants.svcCampgroundURL,
            parameters: [
                "api_key": Constants.svcCampgroundAPIKey,
                "pstate": "CO",
                "pets": "3010"
            ]
            ).responseString { response in
                switch response.result {
                case .success:
                    let xml = SWXMLHash.parse(response.result.value!)
                    
                    for index in 1...xml["resultset"].children.count - 1 {
                        for elem in xml["resultset"] {
                            let value = elem["result"][index].element?.attribute(by: "facilityName")?.text
                            
                            self.data.append(value!)
                        }
                    }
                    // Load the tableview
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell;
        cell.textLabel?.text = self.data[indexPath.row];
    
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You selected cell #\(indexPath.row)!")
    }
}

