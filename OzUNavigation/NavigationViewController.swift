//
//  NavigationViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

class NavigationViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private var regionIds:[Int]!
    private var regionList:[String] = [String]()

    @IBOutlet weak var sourceRegionPicker: UIPickerView!
    @IBOutlet weak var destinationRegionPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let (regionIdsArray, regionListArray) = EntityManager.sharedInstance().getRegionsAsDisplayList()
        self.regionIds = regionIdsArray
        self.regionList = regionListArray
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionList.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.regionList[row]
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBAction func startNavigationButtonTapped() {
        let sourceRow = sourceRegionPicker.selectedRowInComponent(0)
        let sourceRegionId = regionIds[sourceRow]

        let destinationRow = destinationRegionPicker.selectedRowInComponent(0)
        let destinationRegionId = regionIds[destinationRow]

        let path = NavigationManager.sharedInstance().findRoute(fromRegionWithId: sourceRegionId, toRegionWithId: destinationRegionId)

        if path != nil {
            println(path!)
        } else {
            println("There is no path between region with ID:\(sourceRegionId) and ID:\(destinationRegionId)")
        }
    }
}
