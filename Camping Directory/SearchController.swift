//
//  SearchController.swift
//  Camping Directory
//
//  Created by Keith Davis on 9/21/16.
//  Copyright © 2016 ZuniSoft. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
    /*
    var pageData: [String] = []
    var dataObject = ""
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> SearchController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            //return nil
        }
        
        // Create a new view controller and pass suitable data.
        let searchController = storyboard.instantiateViewController(withIdentifier: "SearchController") as! SearchController
        //searchController.dataObject = self.pageData[index]
        return searchController
    }
    
    func indexOfViewController(_ viewController: SearchController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return 0 //pageData.index(of: viewController.dataObject) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! SearchController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! SearchController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    */
}
