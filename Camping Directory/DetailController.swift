//
//  DetailController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/28/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SWXMLHash

class DetailController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate {
    // Segue data
    var sequeData : Data.SearchResult?
    
    // Varibles
    var request: Alamofire.Request?
    let regionRadius: CLLocationDistance = 20000
    var annotation: MKPointAnnotation = MKPointAnnotation()
    
    // Outlets
    @IBOutlet weak var detailScroll: UIScrollView!
    @IBOutlet weak var viewScroll: UIView!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var alertView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directLineView: UITextView!
    @IBOutlet weak var rangerLineView: UITextView!
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Widgets
        self.automaticallyAdjustsScrollViewInsets = false
        
        nameLabel.text = sequeData?.facilityName
        
        // Delegates
        self.detailScroll.delegate = self;
        self.mapView.delegate = self;
        
        // Mapview
        let initialLocation = CLLocation(latitude: Double((sequeData?.latitude)!)!, longitude: Double((sequeData?.longitude)!)!)
        self.centerMapOnLocation(location: initialLocation)

        // Detail URL
        var detailUrl: String = Constants.svcCampgroundDetailURL
        
        // API key
        detailUrl += "?api_key=" + Constants.svcCampgroundAPIKey
        
        // Contract code
        detailUrl += "&contractCode=" + (sequeData?.contractId)!
        
        // Park ID
        detailUrl += "&parkId=" + (sequeData?.facilityId)!
        
        loadData(url: detailUrl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        request?.cancel()
    }
    
    func loadData(url : String) {
        
        request = Alamofire.request(url).responseString { response in
            switch response.result {
            case .success:
                let xml = SWXMLHash.parse(response.result.value!)
                
                for index in 0...xml["detailDescription"].children.count - 1 {
                    for elem in xml["detailDescription"] {
                        if(index == 0) {
                            // Description
                            let note = elem[index].element?.attribute(by: "description")?.text
                            self.noteView.text = note?.stringByDecodingHTMLEntities.stringByDecodingHTMLEntities
                            
                            // Alerts
                            let alert = elem[index].element?.attribute(by: "importantInformation")?.text
                            
                            if(alert != "") {
                                self.alertView.text = alert?.stringByDecodingHTMLEntities.stringByDecodingHTMLEntities
                            } else {
                                self.alertView.text = "No alerts at this time."
                            }
                            
                            // Direct phone
                            var value = elem[index]["contact"][0].element?.attribute(by: "number")?.text
                            if (value != "") {
                                self.directLineView.text = self.formatPhoneNumber(phoneString: value!)
                            }
                            
                            // Rangerstation phone
                            value = elem[index]["contact"][1].element?.attribute(by: "number")?.text
                            if (value != "") {
                                self.rangerLineView.text = self.formatPhoneNumber(phoneString: value!)
                            }
                        }
                    }
                }
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = CLLocationCoordinate2DMake(Double(self.sequeData!.latitude)!, Double((self.sequeData?.longitude)!)!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        mapItem.name = sequeData?.facilityName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
        mapView.deselectAnnotation(annotation, animated: false)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
        annotation.coordinate = coordinateRegion.center
        mapView.addAnnotation(annotation)
    }
    
    func formatPhoneNumber(phoneString: String) -> String {
        let stringToFormat: NSMutableString = NSMutableString(string: phoneString)
        
        stringToFormat.insert("(", at: 0)
        stringToFormat.insert(")", at: 4)
        stringToFormat.insert(" ", at: 5)
        stringToFormat.insert("-", at: 9)
        
        return stringToFormat as String
    }
}
