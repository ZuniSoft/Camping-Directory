//
//  DataViewController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/18/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class DataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    /*
    @IBOutlet weak var dataLabel: UILabel!
    */
    
    var dataObject: String = ""

    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.dataLabel!.text = dataObject
    }
    */
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    var filtered:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        Alamofire.request(
            Constants.svcCampgroundURL,
            parameters: [
                "api_key": Constants.svcCampgroundAPIKey,
                "pstate": "CO",
                "pets": "3010"
            ]
        ).responseString { response in
            
            //print("REQUEST DATA: ")
            //print(response.request)  // original URL request
            //print("RESPONSE DATA: ")
            //print(response.response) // HTTP URL response
            print("XML DATA: ")
            
            
            
            //print(response.data)     // server data
            
            //debugPrint(response.result.value)
            
            //print(response.result)   // result of response serialization
            
            let xml = SWXMLHash.parse(response.result.value!)
            let facilityName = xml["resultset"]["result"][1].element?.attribute(by: "facilityName")?.text
            
            print(facilityName)
            //print(xml["resultset"]["result"][1].element?.attribute(by: "facilityName")?.text)
            
        }
        */
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
        */
        
        searchActive = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell;
        if(searchActive){
            cell.textLabel?.text = filtered[(indexPath as NSIndexPath).row]
        } else {
            cell.textLabel?.text = data[(indexPath as NSIndexPath).row];
        }
        
        return cell;
    }

}

