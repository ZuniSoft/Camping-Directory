//
//  SearchResultsController.swift
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
    var data:[Data.SearchResult] = []
    var request: Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData(url: sequeUrl!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        request?.cancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(url : String) {
        request = Alamofire.request(url).responseString { response in
            switch response.result {
                case .success:
                    let xml = SWXMLHash.parse(response.result.value!)
                    
                    if (xml["resultset"].children.count == 0) {
                        self.alert(message: "No results...")
                        return
                    }
                    
                    for index in 0...xml["resultset"].children.count - 1 {
                        for elem in xml["resultset"] {
                            let contractId = elem["result"][index].element?.attribute(by: "contractID")?.text
                        
                            let fname = elem["result"][index].element?.attribute(by: "facilityName")?.text
                        
                            let fid = elem["result"][index].element?.attribute(by: "facilityID")?.text
                        
                            let lat = elem["result"][index].element?.attribute(by: "latitude")?.text
                        
                            let long = elem["result"][index].element?.attribute(by: "longitude")?.text
                            
                            let power = elem["result"][index].element?.attribute(by: "sitesWithAmps")?.text
                            
                            let water = elem["result"][index].element?.attribute(by: "sitesWithWaterHookup")?.text
                            
                            let sewer = elem["result"][index].element?.attribute(by: "sitesWithSewerHookup")?.text
                        
                            var result: Data.SearchResult! = Data.SearchResult()
                        
                            result.contractId = contractId!
                            result.facilityName = fname!.stringByDecodingHTMLEntities
                            result.facilityId = fid!
                            result.latitude = lat!
                            result.longitude = long!
                            result.power = power!
                            result.water = water!
                            result.sewer = sewer!
                            result.icon = UIImage(named: "Campground")!
                            result.powerIcon = UIImage(named: "ElectricHookups")!
                            result.waterIcon = UIImage(named: "Water")!
                            result.sewerIcon = UIImage(named: "Sewer")!
                        
                            self.data.append(result)
                        }
                        
                    }
                
                // Load the tableview
                self.tableView.reloadData()
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchResultCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchResultCell
        
        let result = self.data[indexPath.row]
        
        cell.FacilityName?.text = result.facilityName.stringByDecodingHTMLEntities;
        cell.FacilityId?.text = result.facilityId;
        cell.powerLabel?.text = result.power;
        cell.waterLabel?.text = result.water;
        cell.sewerLabel?.text = result.sewer;
        cell.Icon?.image = result.icon;
        cell.powerIcon?.image = result.powerIcon;
        cell.waterIcon?.image = result.waterIcon;
        cell.sewerIcon?.image = result.sewerIcon;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Create a new variable to store the instance of DetailController
        let destinationVC = segue.destination as! DetailController
        let selectedRow = tableView.indexPathForSelectedRow!.row
        
        var sequeData = Data.SearchResult()
        
        sequeData.contractId = data[selectedRow].contractId
        sequeData.facilityId = data[selectedRow].facilityId
        sequeData.facilityName = data[selectedRow].facilityName.stringByDecodingHTMLEntities
        sequeData.latitude = data[selectedRow].latitude
        sequeData.longitude = data[selectedRow].longitude
        
        destinationVC.sequeData = sequeData
    }
}
 

