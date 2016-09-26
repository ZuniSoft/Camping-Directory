//
//  SearchController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/21/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerDataSource: [String] = Constants.stateList
    
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var petsAllowedSwitch: UISwitch!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        var petsAllowed = petsAllowedSwitch.isOn ? 0 : 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Connect data:
        self.statePicker.dataSource = self;
        self.statePicker.delegate = self;
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
    private func pickerView(statePicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Create a variable that you want to send
        var newSequeUrl = "Text"
        
        // Create a new variable to store the instance of SearchResultsViewController
        let destinationVC = segue.destination as! SearchResultsController
        destinationVC.sequeUrl = newSequeUrl
    }
}
