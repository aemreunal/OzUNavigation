//
//  NavigationViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

public class NavigationViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, LocationUpdateListenerProtocol {
    private var currentRegion: Region?
    private var currentBeacon: Beacon?

    private var regionIds:[Int]!
    private var regionList:[String] = [String]()

    @IBOutlet weak var sourceRegionPicker: UIPickerView!
    @IBOutlet weak var destinationRegionPicker: UIPickerView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        BeaconManager.sharedInstance().registerForLocationUpdates(self)
        let (regionIdsArray, regionListArray) = EntityManager.sharedInstance().getRegionsAsDisplayList()
        self.regionIds = regionIdsArray
        self.regionList = regionListArray
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentRegion != nil && pickerView == sourceRegionPicker {
            return regionList.count + 1 // +1 for navigating from current location
        }
        return regionList.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if currentRegion != nil && pickerView == sourceRegionPicker {
            if row == 0 {
                return "Current location"
            } else {
                return self.regionList[row - 1]
            }
        }
        return self.regionList[row]
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func didEnterRegion(region:Region?, byDetectingBeacon detectedBeacon:Beacon?) {
        if region == nil {
            self.currentRegion = nil
            self.currentBeacon = nil
        } else {
            self.currentRegion = region!
            self.currentBeacon = detectedBeacon!
        }
        self.sourceRegionPicker.reloadAllComponents()
    }

    @IBAction func startNavigationButtonTapped() {
        let sourceRegionId = getSelectedSourceRegionId()
        let destinationRegionId = getSelectedDestinationRegionId()

        let path = NavigationManager.sharedInstance().findRoute(fromRegionWithId: sourceRegionId, toRegionWithId: destinationRegionId)

        if path != nil {
            println(path!)
        } else {
            println("There is no path between region with ID:\(sourceRegionId) and ID:\(destinationRegionId)")
        }
    }

    private func getSelectedSourceRegionId() -> Int {
        let sourceRow = sourceRegionPicker.selectedRowInComponent(0)
        if currentRegion != nil {
            if sourceRow == 0 { // If "Current location" is chosen as source region
                return currentRegion!.id
            } else {
                return regionIds[sourceRow - 1]
            }
        }
        return regionIds[sourceRow]
    }

    private func getSelectedDestinationRegionId() -> Int {
        let destinationRow = destinationRegionPicker.selectedRowInComponent(0)
        return regionIds[destinationRow]
    }
}
