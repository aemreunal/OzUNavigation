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

    private var calculatedPath: [Int]! // Used for storing the path after it's computed in shouldPerformSegue, for prepareForSegue

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

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startNavigationSegue" {
            let destination = segue.destinationViewController as! NavigationDirectionViewController
            destination.path = self.calculatedPath
        }
    }

    public override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let segueIdentifier = identifier {
            if segueIdentifier == "startNavigationSegue" {
                let sourceRegionId = getSelectedSourceRegionId()
                let destinationRegionId = getSelectedDestinationRegionId()

                // Check whether you're trying to navigate to the same region
                if sourceRegionId == destinationRegionId {
                    let destinationAlert = UIAlertController(title: "Same Region", message: "You're already at your destination!", preferredStyle: UIAlertControllerStyle.Alert)
                    destinationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.showViewController(destinationAlert, sender: self)
                    return false
                }

                // Check whether there is a path
                let path = NavigationManager.sharedInstance().findRoute(fromRegionWithId: sourceRegionId, toRegionWithId: destinationRegionId)
                if path == nil {
                    let destinationAlert = UIAlertController(title: "No Route", message: "There are no routes between the selected places.", preferredStyle: UIAlertControllerStyle.Alert)
                    destinationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.showViewController(destinationAlert, sender: self)
                    return false                }

                // Store calculated path, perform segue
                self.calculatedPath = path!
                return true
            }
        }
        return true
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
