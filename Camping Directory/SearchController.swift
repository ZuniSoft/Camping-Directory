//
//  SearchController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/21/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate {
    
    var pickerDataSource: [String] = Constants.stateList
    var statePickerValue: String = ""
    
    
    @IBOutlet weak var optionScroll: UIScrollView!
    @IBOutlet weak var viewScroll: UIView!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var maxPeopleField: UITextField!
    @IBOutlet weak var cgNameField: UITextField!
    @IBOutlet weak var rvLengthField: UITextField!
    @IBOutlet weak var petsAllowedSwitch: UISwitch!
    @IBOutlet weak var waterSwitch: UISwitch!
    @IBOutlet weak var sewerSwitch: UISwitch!
    @IBOutlet weak var pullThroughSwitch: UISwitch!
    @IBOutlet weak var waterFrontSwitch: UISwitch!
    @IBOutlet weak var ampsAvailableSegment: UISegmentedControl!
    @IBOutlet weak var facilityTypeSegment: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Connect data:
        self.statePicker.dataSource = self;
        self.statePicker.delegate = self;
        
        self.optionScroll.delegate = self
        
        // Defaults
        self.statePicker.selectedRow(inComponent: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // The number of columns of data.
    func numberOfComponents(in statePicker: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data.
    func pickerView(_ statePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    // The data to return for the row and component (column) that's being passed in.
    func pickerView(_ statePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    // The row selected in the picker by the user.
    func pickerView(_ statePicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        statePickerValue = Constants.stateDictionary[Constants.stateList[row]]!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Create a variable that you want to send
        var newSequeUrl : String
        
        // API url
        newSequeUrl = Constants.svcCampgroundURL
        
        // API key
        newSequeUrl += "?api_key=" + Constants.svcCampgroundAPIKey
        
        // State
        newSequeUrl += "&pstate=" + statePickerValue
        
        // Pets allowed
        let petsAllowedValue = petsAllowedSwitch.isOn ? 3010 : 0
        if petsAllowedValue == 3010 {
            newSequeUrl += "&pets=" + String(petsAllowedValue)
        }
        
        // Create a new variable to store the instance of SearchResultsViewController
        let destinationVC = segue.destination as! SearchResultsController
        destinationVC.sequeUrl = newSequeUrl
    }
}
