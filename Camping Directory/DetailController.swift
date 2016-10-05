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

class DetailController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Segue data
    var sequeData : Data.SearchResult?
    
    // Varibles
    var request: Alamofire.Request?
    let regionRadius: CLLocationDistance = 20000
    var annotation: MKPointAnnotation = MKPointAnnotation()
    var amenities:[Data.AmenityResult] = []

    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
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
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        
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
                            
                            if(alert != "" || alert != ".") {
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
                            
                            for amenity in elem[index]["amenity"].all {
                                var ammenities: Data.AmenityResult! = Data.AmenityResult()
                                
                                let aDesc = (amenity.element?.attribute(by: "name")?.text)!
                                let aLoc = (amenity.element?.attribute(by: "distance")?.text)!
                                
                                ammenities.amenityDescription = aDesc.stringByDecodingHTMLEntities
                                ammenities.amenityLocation = aLoc.stringByDecodingHTMLEntities
                                
                                switch ammenities.amenityDescription {
                                    case "Accessible Flush Toilets":
                                        ammenities.amenityIcon = UIImage(named: "Accessible")!
                                        break;
                                    case "Accessible Sites":
                                        ammenities.amenityIcon = UIImage(named: "Accessible")!
                                        break;
                                    case "Beach Access":
                                        ammenities.amenityIcon = UIImage(named: "BeachAccess")!
                                        break;
                                    case "Biking":
                                        ammenities.amenityIcon = UIImage(named: "Biking")!
                                        break;
                                    case "Bird Watching":
                                        ammenities.amenityIcon = UIImage(named: "BirdWatching")!
                                        break;
                                    case "Boating":
                                        ammenities.amenityIcon = UIImage(named: "Boating")!
                                        break;
                                    case "Drinking Water":
                                        ammenities.amenityIcon = UIImage(named: "DrinkingWater")!
                                        break;
                                    case "Dump Station":
                                        ammenities.amenityIcon = UIImage(named: "DumpStation")!
                                        break;
                                    case "Educational Programs":
                                        ammenities.amenityIcon = UIImage(named: "EducationalPrograms")!
                                        break;
                                    case "Electric Hookups":
                                        ammenities.amenityIcon = UIImage(named: "ElectricHookups")!
                                        break;
                                    case "Entrance Station":
                                        ammenities.amenityIcon = UIImage(named: "EntranceStation")!
                                        break;
                                    case "Firewood Vendor":
                                        ammenities.amenityIcon = UIImage(named: "FirewoodVendor")!
                                        break;
                                    case "Fishing":
                                        ammenities.amenityIcon = UIImage(named: "Fishing")!
                                        break;
                                    case "Flush Toilets":
                                        ammenities.amenityIcon = UIImage(named: "FlushToilets")!
                                        break;
                                    case "Grills":
                                        ammenities.amenityIcon = UIImage(named: "Grills")!
                                        break;
                                    case "Hiking":
                                        ammenities.amenityIcon = UIImage(named: "Hiking")!
                                        break;
                                    case "Host":
                                        ammenities.amenityIcon = UIImage(named: "Host")!
                                        break;
                                    case "Ice Machine":
                                        ammenities.amenityIcon = UIImage(named: "IceMachine")!
                                        break;
                                    case "Jet Skiing":
                                        ammenities.amenityIcon = UIImage(named: "JetSkiing")!
                                        break;
                                    case "Lake Access":
                                        ammenities.amenityIcon = UIImage(named: "LakeAccess")!
                                        break;
                                    case "Non-Motorized Boating":
                                        ammenities.amenityIcon = UIImage(named: "Non-MotorizedBoating")!
                                        break;
                                    case "Parking Area":
                                        ammenities.amenityIcon = UIImage(named: "ParkingArea")!
                                        break;
                                    case "Pay Phone":
                                        ammenities.amenityIcon = UIImage(named: "PayPhone")!
                                        break;
                                    case "Pets Allowed":
                                        ammenities.amenityIcon = UIImage(named: "PetsAllowed")!
                                        break;
                                    case "Picnic Shelters":
                                        ammenities.amenityIcon = UIImage(named: "PicnicShelters")!
                                        break;
                                    case "Showers":
                                        ammenities.amenityIcon = UIImage(named: "Showers")!
                                        break;
                                    case "Tent Pads":
                                        ammenities.amenityIcon = UIImage(named: "TentPads")!
                                        break;
                                    case "Water Skiing":
                                        ammenities.amenityIcon = UIImage(named: "WaterSkiing")!
                                        break;
                                    default:
                                        ammenities.amenityIcon = UIImage(named: "AmenityDefault")!
                                    break;
                                }
                                
                                self.amenities.append(ammenities)
                            }
                        }
                    }
                }
                self.collectionView.reloadData()
            case .failure(let error):
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.amenities.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! AmenityCell
        
        cell.amenityLabel.text = self.amenities[indexPath.item].amenityDescription
        cell.amenityLocationLabel.text = self.amenities[indexPath.item].amenityLocation
        cell.amenityIcon.image = self.amenities[indexPath.item].amenityIcon
        //cell.backgroundColor = UIColor.lightGray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
