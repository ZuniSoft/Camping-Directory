//
//  DetailController.swift
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
    let regionRadius: CLLocationDistance = 15000
    var initialLocation: CLLocation?
    var annotation: MKPointAnnotation = MKPointAnnotation()
    var amenities:[Data.AmenityResult] = []

    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailScroll: UIScrollView!
    @IBOutlet weak var viewScroll: UIView!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var alertView: UITextView!
    @IBOutlet weak var addressView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directLineView: UITextView!
    @IBOutlet weak var rangerLineView: UITextView!
    @IBOutlet weak var reservationUrlView: UITextView!
    @IBOutlet weak var activeLogoView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Widgets
        self.automaticallyAdjustsScrollViewInsets = false
        
        nameLabel.text = sequeData?.facilityName
        
        activeLogoView.image = UIImage(named: "ActiveLogo")!
        
        // Delegates
        self.detailScroll.delegate = self;
        self.mapView.delegate = self;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
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
                
                if (xml["detailDescription"].children.count == 0) {
                    self.alert(message: "No detail available...")
                    return
                }
                
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
                            
                            // Address
                            let street = elem[index]["address"][0].element?.attribute(by: "streetAddress")?.text
                            let city = elem[index]["address"][0].element?.attribute(by: "city")?.text
                            let state = elem[index]["address"][0].element?.attribute(by: "state")?.text
                            let zipcode = elem[index]["address"][0].element?.attribute(by: "zip")?.text
                            
                            var address = street != "" ? street! + ", " : ""
                            address += city != "" ? city! + ", " : ""
                            address += state != "" ? state! + " " : ""
                            address += zipcode != "" ? zipcode! : ""
                            
                            address = address.stringByDecodingHTMLEntities
                            
                            self.addressView.text = address
                            
                            // Mapview lat and long
                            if (self.sequeData?.latitude != "" && self.sequeData?.longitude != "") {
                                self.initialLocation = CLLocation(latitude: Double((self.sequeData?.latitude)!)!, longitude: Double((self.sequeData?.longitude)!)!)
                                self.centerMapOnLocation(location: self.initialLocation!)
                            // Mapview address
                            } else if (address != "" && (self.sequeData?.latitude == "" && self.sequeData?.longitude == "")) {
                                
                                var placemark: CLPlacemark!
                                
                                CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
                                    if error == nil {
                                        
                                        placemark = (placemarks?[0])! as CLPlacemark
                                        
                                        self.initialLocation = CLLocation(latitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)!)
                                        self.centerMapOnLocation(location: self.initialLocation!)
                                    }
                                })
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
                            
                            // Reservation URL
                            let reservationUrl = elem[index].element?.attribute(by: "reservationUrl")?.text
                                
                            let url = Constants.svcCampsiteReservationURL + reservationUrl!
                            let msg = "Reserve America" as NSString
                            let range = msg.range(of: "Reserve America")
                            
                            let attributedString = NSMutableAttributedString(string: msg as String)
                            attributedString.addAttribute(NSLinkAttributeName, value: NSURL(string: url)!, range: range)
                            
                            self.reservationUrlView.attributedText = attributedString
                            self.reservationUrlView.font = .systemFont(ofSize: 14)
                            
                            
                            // Ammentities
                            for amenity in elem[index]["amenity"].all {
                                var ammenities: Data.AmenityResult! = Data.AmenityResult()
                                
                                let aDesc = (amenity.element?.attribute(by: "name")?.text)!
                                let aLoc = (amenity.element?.attribute(by: "distance")?.text)!
                                
                                debugPrint("Amenity Description: " + aDesc)
                                
                                ammenities.amenityDescription = aDesc.stringByDecodingHTMLEntities
                                ammenities.amenityLocation = aLoc.stringByDecodingHTMLEntities
                                
                                switch ammenities.amenityDescription.trimmingCharacters(in: NSCharacterSet.whitespaces) {
                                case "Accessible Flush Toilets", "Accessible Vault Toilets", "Toilet, Accessible", "Ada Accessible Pit Restroom", "Ada Accessible Restroom":
                                    ammenities.amenityIcon = UIImage(named: "Accessible")!
                                    break;
                                case "Accessible Sites", "ADA Access", "Hiking Accessible", "ADA Accessible", "Ada Accessible Hiking Trails", "Ada Accessible Swimming", "Accessible Boat Ramp", "Accessible Playground", "Accessible Fishing Dock", "Accessible Campsites", "Accessible Grills", "Accessible Parking", "Accessible Picnic Areas", "Accessible Scenic Overlook", "Accessible Walkways", "Accessible Swimming", "Accessible Trails":
                                    ammenities.amenityIcon = UIImage(named: "Accessible")!
                                    break;
                                case "Baseball Field":
                                    ammenities.amenityIcon = UIImage(named: "Baseball")!
                                    break;
                                case "Basketball Courts", "Basketball Court":
                                    ammenities.amenityIcon = UIImage(named: "BasketballCourts")!
                                    break;
                                case "Beach Access", "Beach":
                                    ammenities.amenityIcon = UIImage(named: "BeachAccess")!
                                    break;
                                case "Biking", "Mountain Biking", "Bike Rentals", "Bicycling":
                                    ammenities.amenityIcon = UIImage(named: "Biking")!
                                    break;
                                case "Bird Watching", "Birdwatching", "Birding":
                                    ammenities.amenityIcon = UIImage(named: "BirdWatching")!
                                    break;
                                case "Boating", "Boat Rentals", "Boat Ramp", "Dock", "Boat Trailer Parking":
                                    ammenities.amenityIcon = UIImage(named: "Boating")!
                                    break;
                                case "Climbing":
                                    ammenities.amenityIcon = UIImage(named: "Climbing")!
                                    break;
                                case "Creek Access", "River Access":
                                    ammenities.amenityIcon = UIImage(named: "CreekAccess")!
                                    break;
                                case "Cross Country Skiing":
                                    ammenities.amenityIcon = UIImage(named: "CrossCountrySkiing")!
                                    break;
                                case "Drinking Water", "Water", "Drinking Water (Peak Season)", "Potable Water", "Public Drinking Water Taps", "Water Faucets", "Water Drinking":
                                    ammenities.amenityIcon = UIImage(named: "DrinkingWater")!
                                    break;
                                case "Dump Station":
                                    ammenities.amenityIcon = UIImage(named: "DumpStation")!
                                    break;
                                case "Educational Programs", "Interpretitive Programs", "Nature Study Exhibits", "Interpretitive Trails", "Campfire Programs", "Interpretive Trails", "Backpacking Camping", "Backpacking", "Interpretive Exhibit / Display", "Interpretive Trail":
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
                                case "Fire Tower":
                                    ammenities.amenityIcon = UIImage(named: "FireTower")!
                                    break;
                                case "Fishing", "Fish Cleaning Stations", "Pond and Stream Fishing", "Fishing Pier", "Fish Hatchery", "Fishing, River / Stream":
                                    ammenities.amenityIcon = UIImage(named: "Fishing")!
                                    break;
                                case "Flush Toilets", "Flush Toilet", "Vault Toilets", "Comfort Station", "Pit Toilets", "Pit Toilet", "Restrooms", "Restroom":
                                    ammenities.amenityIcon = UIImage(named: "FlushToilets")!
                                    break;
                                case "Food Storage Locker", "Food storage lockers":
                                    ammenities.amenityIcon = UIImage(named: "FoodLocker")!
                                    break;
                                case "Fuel Available", "Fuel Vehicles":
                                    ammenities.amenityIcon = UIImage(named: "FuelAvailable")!
                                    break;
                                case "General Store", "Grocery Store", "Store", "Store - Convenience", "Convenience Store":
                                    ammenities.amenityIcon = UIImage(named: "GeneralStore")!
                                    break;
                                case "Grills", "Campfire Rings", "Fire Rings", "Campfire Circles", "Fireplace":
                                    ammenities.amenityIcon = UIImage(named: "Grills")!
                                    break;
                                case "Group Campground", "Group Camping", "Group Camping Facility", "Group Shelters", "Group / Community Facility":
                                    ammenities.amenityIcon = UIImage(named: "GroupCampground")!
                                    break;
                                case "Hiking":
                                    ammenities.amenityIcon = UIImage(named: "Hiking")!
                                    break;
                                case "Historic Sites", "Historic Structure / Feature":
                                    ammenities.amenityIcon = UIImage(named: "HistoricSites")!
                                    break;
                                case "Horseback Riding", "Equestrian Sites", "Pack Station", "Horseback Riding Trails", "Camping, Equestrian":
                                    ammenities.amenityIcon = UIImage(named: "HorsebackRiding")!
                                    break;
                                case "Horseshoe Pit", "Horseshoe Pits", "Horse Shoe Pit":
                                    ammenities.amenityIcon = UIImage(named: "HorseshoePit")!
                                    break;
                                case "Hospital":
                                    ammenities.amenityIcon = UIImage(named: "Hospital")!
                                    break;
                                case "Host", "Park Attendant", "CAMPGROUND HOST":
                                    ammenities.amenityIcon = UIImage(named: "Host")!
                                    break;
                                case "Hunting":
                                    ammenities.amenityIcon = UIImage(named: "Hunting")!
                                    break;
                                case "Ice Machine", "Ice":
                                    ammenities.amenityIcon = UIImage(named: "IceMachine")!
                                    break;
                                case "Jet Skiing":
                                    ammenities.amenityIcon = UIImage(named: "JetSkiing")!
                                case "Kayaking", "Canoeing":
                                    ammenities.amenityIcon = UIImage(named: "Kayaking")!
                                    break;
                                case "Lake Access", "Water Access":
                                    ammenities.amenityIcon = UIImage(named: "LakeAccess")!
                                    break;
                                case "Laundry Facilities", "Laundry":
                                    ammenities.amenityIcon = UIImage(named: "LaundryFacilities")!
                                    break;
                                case "Non-Motorized Boating", "Marina", "Sailing":
                                    ammenities.amenityIcon = UIImage(named: "Non-MotorizedBoating")!
                                    break;
                                case "Off-Road Vehicle Trails", "Off-Highway Vehicle Recreation":
                                    ammenities.amenityIcon = UIImage(named: "Off-RoadVehicleTrails")!
                                    break;
                                case "Parking Area", "Parking":
                                    ammenities.amenityIcon = UIImage(named: "ParkingArea")!
                                    break;
                                case "Pay Phone", "Telephone":
                                    ammenities.amenityIcon = UIImage(named: "PayPhone")!
                                    break;
                                case "Pets Allowed":
                                    ammenities.amenityIcon = UIImage(named: "PetsAllowed")!
                                    break;
                                case "Photography":
                                    ammenities.amenityIcon = UIImage(named: "Photography")!
                                    break;
                                case "Picnic Area", "Picnicking", "Picnicing":
                                    ammenities.amenityIcon = UIImage(named: "PicnicArea")!
                                    break;
                                case "Picnic Shelters":
                                    ammenities.amenityIcon = UIImage(named: "PicnicShelters")!
                                    break;
                                case "Play Field", "Field Sports", "Multi-Use Court":
                                    ammenities.amenityIcon = UIImage(named: "PlayField")!
                                    break;
                                case "Playground":
                                    ammenities.amenityIcon = UIImage(named: "Playground")!
                                    break;
                                case "Ranger Station", "Office/Ranger Station":
                                    ammenities.amenityIcon = UIImage(named: "RangerStation")!
                                    break;
                                case "Recycling", "Recycling Center":
                                    ammenities.amenityIcon = UIImage(named: "Recycling")!
                                    break;
                                case "Restaurant", "Cafe", "Cafe/Restaurant":
                                    ammenities.amenityIcon = UIImage(named: "Restaurant")!
                                    break;
                                case "RV sites", "RV Parking":
                                    ammenities.amenityIcon = UIImage(named: "RVSites")!
                                    break;
                                case "Self Pay Station", "Fee Station":
                                    ammenities.amenityIcon = UIImage(named: "SelfPayStation")!
                                    break;
                                case "Sewer Hookups":
                                    ammenities.amenityIcon = UIImage(named: "Sewer")!
                                    break;
                                case "Showers":
                                    ammenities.amenityIcon = UIImage(named: "Showers")!
                                    break;
                                case "Ice Skating":
                                    ammenities.amenityIcon = UIImage(named: "Skating")!
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
                                case "Soccer Field":
                                    ammenities.amenityIcon = UIImage(named: "Soccer")!
                                    break;
                                case "Swimming", "Water Sports":
                                    ammenities.amenityIcon = UIImage(named: "Swimming")!
                                    break;
                                case "Tables", "Picnic Tables":
                                    ammenities.amenityIcon = UIImage(named: "Tables")!
                                    break;
                                case "Tennis Courts":
                                    ammenities.amenityIcon = UIImage(named: "Tennis")!
                                    break;
                                case "Tent Pads", "Tent sites", "Site Pads":
                                    ammenities.amenityIcon = UIImage(named: "TentPads")!
                                    break;
                                case "Trailheads", "Trails", "Hiking Trails", "Nature Trails", "Hiking Trail":
                                    ammenities.amenityIcon = UIImage(named: "Trailheads")!
                                    break;
                                case "Trash Collection", "Dumpster":
                                    ammenities.amenityIcon = UIImage(named: "TrashCollection")!
                                    break;
                                case "Vending Machines":
                                    ammenities.amenityIcon = UIImage(named: "VendingMachines")!
                                    break;
                                case "Visitors Center", "Visitor Center", "Camper Services Bldg", "Administrative Office", "Information Station", "Information / Contact Station":
                                    ammenities.amenityIcon = UIImage(named: "VisitorCenter")!
                                    break;
                                case "Volleyball", "Volleyball Courts", "Volleyball Court":
                                    ammenities.amenityIcon = UIImage(named: "VolleyballCourts")!
                                    break;
                                case "Water Skiing", "Windsurfing":
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
        let coordinate = CLLocationCoordinate2DMake((initialLocation?.coordinate.latitude)!, (initialLocation?.coordinate.longitude)!)
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
