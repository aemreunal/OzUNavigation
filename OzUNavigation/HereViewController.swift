//
//  HereViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 17/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

class HereViewController : UIViewController {
    let beaconManager = BeaconManager.sharedInstance()

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!

    override func viewDidAppear(animated: Bool) {
        askForLocationAuthorization()
    }

    private func askForLocationAuthorization() {
        switch beaconManager.locationAuthorizationStatus() {
        case .CanAsk:
            requestLocationAuthorization()
            // TODO Add different messages for different situations
        case .Authorized:
            beaconManager.startRangingBeacons()
        default:
            println("Not allowed")
        }
    }

    private func requestLocationAuthorization() {
        let alertController = UIAlertController(title: "Location Authorization", message: "In order to show you your current location and help you navigate, you must allow the use of Location Services. Would you like to allow?", preferredStyle: UIAlertControllerStyle.Alert)

        let allowAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) -> Void in
            self.beaconManager.requestAuthorization()
        }
        alertController.addAction(allowAction)

        let disallowAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) -> Void in
            println("Didn't allow")
        }
        alertController.addAction(disallowAction)

        presentViewController(alertController, animated: true, completion: nil)
    }
}
