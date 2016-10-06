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
                                case "Basketball Courts":
                                    ammenities.amenityIcon = UIImage(named: "BasketballCourts")!
                                    break;
                                case "Beach Access":
                                    ammenities.amenityIcon = UIImage(named: "BeachAccess")!
                                    break;
                                case "Biking", "Mountain Biking":
                                    ammenities.amenityIcon = UIImage(named: "Biking")!
                                    break;
                                case "Bird Watching", "Birding":
                                    ammenities.amenityIcon = UIImage(named: "BirdWatching")!
                                    break;
                                case "Boating", "Boat Rentals":
                                    ammenities.amenityIcon = UIImage(named: "Boating")!
                                    break;
                                case "Climbing":
                                    ammenities.amenityIcon = UIImage(named: "Climbing")!
                                    break;
                                case "Creek Access":
                                    ammenities.amenityIcon = UIImage(named: "CreekAccess")!
                                    break;
                                case "Cross Country Skiing":
                                    ammenities.amenityIcon = UIImage(named: "CrossCountrySkiing")!
                                    break;
                                case "Drinking Water", "Water":
                                    ammenities.amenityIcon = UIImage(named: "DrinkingWater")!
                                    break;
                                case "Dump Station":
                                    ammenities.amenityIcon = UIImage(named: "DumpStation")!
                                    break;
                                case "Educational Programs", "Interpretitive Programs", "Nature Study Exhibits", "Interpretitive Trails":
                                    ammenities.amenityIcon = UIImage(named: "EducationalPrograms")!
                                    break;
                                case "Electric Hookups":
                                    ammenities.amenityIcon = UIImage(named: "ElectricHookups")!
                                    break;
                                case "Entrance Station":
                                    ammenities.amenityIcon = UIImage(named: "EntranceStation")!
                                    break;
                                case "Firewood Vendor", "Firewood", "Firewood Available":
                                    ammenities.amenityIcon = UIImage(named: "FirewoodVendor")!
                                    break;
                                case "Fishing":
                                    ammenities.amenityIcon = UIImage(named: "Fishing")!
                                    break;
                                case "Flush Toilets", "Vault Toilets", "Comfort Station":
                                    ammenities.amenityIcon = UIImage(named: "FlushToilets")!
                                    break;
                                case "Fuel Available":
                                    ammenities.amenityIcon = UIImage(named: "FuelAvailable")!
                                    break;
                                case "General Store":
                                    ammenities.amenityIcon = UIImage(named: "GeneralStore")!
                                    break;
                                case "Grills", "Campfire Rings":
                                    ammenities.amenityIcon = UIImage(named: "Grills")!
                                    break;
                                case "Group Campground", "Group Camping":
                                    ammenities.amenityIcon = UIImage(named: "GroupCampground")!
                                    break;
                                case "Hiking":
                                    ammenities.amenityIcon = UIImage(named: "Hiking")!
                                    break;
                                case "Historic Sites":
                                    ammenities.amenityIcon = UIImage(named: "HistoricSites")!
                                    break;
                                case "Horseback Riding":
                                    ammenities.amenityIcon = UIImage(named: "HorsebackRiding")!
                                    break;
                                case "Horseshoe Pit":
                                    ammenities.amenityIcon = UIImage(named: "HorseshoePit")!
                                    break;
                                case "Host":
                                    ammenities.amenityIcon = UIImage(named: "Host")!
                                    break;
                                case "Hunting":
                                    ammenities.amenityIcon = UIImage(named: "Hunting")!
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
                                case "Laundry Facilities":
                                    ammenities.amenityIcon = UIImage(named: "LaundryFacilities")!
                                    break;
                                case "Non-Motorized Boating", "Marina":
                                    ammenities.amenityIcon = UIImage(named: "Non-MotorizedBoating")!
                                    break;
                                case "Off-Road Vehicle Trails":
                                    ammenities.amenityIcon = UIImage(named: "Off-RoadVehicleTrails")!
                                    break;
                                case "Parking Area", "Parking":
                                    ammenities.amenityIcon = UIImage(named: "ParkingArea")!
                                    break;
                                case "Pay Phone":
                                    ammenities.amenityIcon = UIImage(named: "PayPhone")!
                                    break;
                                case "Pets Allowed":
                                    ammenities.amenityIcon = UIImage(named: "PetsAllowed")!
                                    break;
                                case "Photography":
                                    ammenities.amenityIcon = UIImage(named: "Photography")!
                                    break;
                                case "Picnic Area", "Picnicking":
                                    ammenities.amenityIcon = UIImage(named: "PicnicArea")!
                                    break;
                                case "Picnic Shelters":
                                    ammenities.amenityIcon = UIImage(named: "PicnicShelters")!
                                    break;
                                case "Playground":
                                    ammenities.amenityIcon = UIImage(named: "Playground")!
                                    break;
                                case "Ranger Station":
                                    ammenities.amenityIcon = UIImage(named: "RangerStation")!
                                    break;
                                case "Recycling":
                                    ammenities.amenityIcon = UIImage(named: "Recycling")!
                                    break;
                                case "Self Pay Station":
                                    ammenities.amenityIcon = UIImage(named: "SelfPayStation")!
                                    break;
                                case "Showers":
                                    ammenities.amenityIcon = UIImage(named: "Showers")!
                                    break;
                                case "Skiing":
                                    ammenities.amenityIcon = UIImage(named: "Skiing")!
                                    break;
                                case "Snow Shoeing", "Snow Sledding":
                                    ammenities.amenityIcon = UIImage(named: "SnowShoeing")!
                                    break;
                                case "Snow Sledding":
                                    ammenities.amenityIcon = UIImage(named: "SnowSledding")!
                                    break;
                                case "Swimming":
                                    ammenities.amenityIcon = UIImage(named: "Swimming")!
                                    break;
                                case "Tables", "Picnic Tables":
                                    ammenities.amenityIcon = UIImage(named: "Tables")!
                                    break;
                                case "Tent Pads", "Tent sites":
                                    ammenities.amenityIcon = UIImage(named: "TentPads")!
                                    break;
                                case "Trailheads":
                                    ammenities.amenityIcon = UIImage(named: "Trailheads")!
                                    break;
                                case "Trash Collection":
                                    ammenities.amenityIcon = UIImage(named: "TrashCollection")!
                                    break;
                                case "Vending Machines":
                                    ammenities.amenityIcon = UIImage(named: "VendingMachines")!
                                    break;
                                case "Visitor Center", "Camper Services Bldg":
                                    ammenities.amenityIcon = UIImage(named: "VisitorCenter")!
                                    break;
                                case "Volleyball Courts":
                                    ammenities.amenityIcon = UIImage(named: "VolleyballCourts")!
                                    break;
                                case "Water Skiing":
                                    ammenities.amenityIcon = UIImage(named: "WaterSkiing")!
                                    break;
                                case "Wildlife Viewing", "Wildlife Watching Opportunity":
                                    ammenities.amenityIcon = UIImage(named: "WildlifeViewing")!
                                    break;
                                default:
                                    if(aDesc != "") {
                                        ammenities.amenityIcon = UIImage(named: "AmenityDefault")!
                                    }
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
