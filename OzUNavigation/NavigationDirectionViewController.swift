//
//  NavigationDirectionViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 18/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit
import Kingfisher

public class NavigationDirectionViewController : UIViewController, LocationUpdateListenerProtocol {
    private var destinationRegion:Region!

    public var path:[Int]!
    // The index of the current entity on the path array
    // An even number means it's a region, an odd number means it's a connection
    private var positionOnPath = 0
    // The next beacon on the path
    // When reached, we should jump to the next instruction on the path
    private var beaconToReach:Beacon!
    // Flag to immediately stop receiving location updates after arrival
    private var navigationHasStopped = false

    private let beaconManager = BeaconManager.sharedInstance()
    private let entityManager = EntityManager.sharedInstance()

    private var locationUpdateListenerQueueIndex:Int!

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UINavigationItem!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.locationUpdateListenerQueueIndex = beaconManager.registerForLocationUpdates(self)

        // Set up
        self.destinationRegion = entityManager.getRegion(ID: self.path.last!)
        if let destinationRegionName = destinationRegion.displayName {
            self.titleLabel.title = "To: \(destinationRegionName)"
        } else {
            self.titleLabel.title = "Navigating"
        }
        updateInstructions()
    }

    public func didEnterRegion(region:Region?, byDetectingBeacon detectedBeacon:Beacon?) {
        if navigationHasStopped {
            return
        }
        if let currentRegion = region {
            if currentRegion == self.destinationRegion { // We have arrived at our destination
                endNavigationWithSuccess()
            } else {
                if detectedBeacon! == self.beaconToReach { // We've reached the designated beacon
                    self.positionOnPath++
                    updateInstructions()
                }
            }
        } else { // Location information is no longer available

            // Not doing these because after the location information returns, the
            // instructions are not updated, as it's not the expected beacon, which
            // doesn't trigger an update

            //            self.directionLabel.text = "(Unable to determine your location)"
            //            self.imageView.image = nil
        }
    }

    private func updateInstructions() {
        // Get the beacon to reach
        if self.positionOnPath % 2 == 0 { // True if current position on path is a region
            // Set the current image
            self.imageView.kf_setImageWithURL(NSURL(string: ServerDataManager.sharedInstance().getRegionImageUrl(self.path[self.positionOnPath]))!)
            // Next point on the path is a connection
            self.beaconToReach = entityManager.getBeaconOfConnectionWithID(self.path[self.positionOnPath + 1], atRegionWithID: self.path[self.positionOnPath])
        } else { // False if current position on path is a connection
            // Set the current image
            self.imageView.kf_setImageWithURL(NSURL(string: ServerDataManager.sharedInstance().getConnectionImageUrl(self.path[self.positionOnPath]))!)
            // Next point on the path is a region
            self.beaconToReach = entityManager.getBeaconOfConnectionWithID(self.path[self.positionOnPath], atRegionWithID: self.path[self.positionOnPath + 1])
        }

        // Update direction label
        if let beaconName = self.beaconToReach.displayName {
            self.directionLabel.text = "Please proceed to:\n\(beaconName)"
        } else {
            self.directionLabel.text = "Please proceed to the indicated point."
        }
    }

    @IBAction func stopButtonTapped(sender: UIBarButtonItem) {
        let confirmationAlert = UIAlertController(title: "Stop Navigation", message: "Are you sure you want to stop the navigation?", preferredStyle: UIAlertControllerStyle.Alert)
        confirmationAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            self.stopNavigation()
        }))
        confirmationAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        self.showViewController(confirmationAlert, sender: self)
    }

    private func endNavigationWithSuccess() {
        navigationHasStopped = true
        let arrivedAlert = UIAlertController(title: "Arrived", message: "You have arrived at your destination!", preferredStyle: UIAlertControllerStyle.Alert)
        arrivedAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            self.stopNavigation()
        }))
        self.showViewController(arrivedAlert, sender: self)
    }

    private func stopNavigation() {
        beaconManager.deregisterFromLocationUpdates(self.locationUpdateListenerQueueIndex)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
