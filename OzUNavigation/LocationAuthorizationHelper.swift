//
//  LocationAuthorizationHelper.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 23/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

public class LocationAuthorizationHelper {
    private static let beaconManager = BeaconManager.sharedInstance()

    public class func askForLocationAuthorization(tabBarController: UITabBarController) {
        switch beaconManager.locationAuthorizationStatus() {
        case .NotEnabled:
            println("LS not enabled")
            showNotEnabledAlert(tabBarController)
        case .NotAuthorized:
            println("Unauthorized")
            showNotAuhtorizedAlert(tabBarController)
        case .BluetoothDisabled:
            println("BT not enabled")
            showBluetoothDisabledAlert(tabBarController)
        case .CanAsk:
            println("Can ask")
            requestLocationAuthorization(tabBarController)
        case .Authorized:
            println("Start ranging")
            beaconManager.startRangingBeacons()
        default:
            println("Exhausted the options")
        }
    }

    private class func requestLocationAuthorization(tabBarController: UITabBarController) {
        let alertController = UIAlertController(title: "Location Authorization", message: "In order to show you your current location and help you navigate, you must allow the use of Location Services. Would you like to allow?", preferredStyle: UIAlertControllerStyle.Alert)

        let allowAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            self.beaconManager.requestAuthorization()
        }
        alertController.addAction(allowAction)

        let disallowAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            tabBarController.selectedIndex = 0
            println("Didn't allow")
        }
        alertController.addAction(disallowAction)

        tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }

    private class func showNotEnabledAlert(tabBarController: UITabBarController) {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "In order to show you your current location and help you navigate, Location Services must be enabled. Please enable location services through Settings.", preferredStyle: UIAlertControllerStyle.Alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            tabBarController.selectedIndex = 0
        }
        alertController.addAction(okAction)
        tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }

    private class func showNotAuhtorizedAlert(tabBarController: UITabBarController) {
        let alertController = UIAlertController(title: "Location Use Not Authorized", message: "In order to show you your current location and help you navigate, Location use must be authorized. Please enable location use through Settings.", preferredStyle: UIAlertControllerStyle.Alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            tabBarController.selectedIndex = 0
        }
        alertController.addAction(okAction)
        tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }

    private class func showBluetoothDisabledAlert(tabBarController: UITabBarController) {
        let alertController = UIAlertController(title: "Bluetooth Disabled", message: "In order to show you your current location and help you navigate, Bluetooth must be turned on. Please turn Bluetooth on through Settings or Control Center.", preferredStyle: UIAlertControllerStyle.Alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            tabBarController.selectedIndex = 0
        }
        alertController.addAction(okAction)
        tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }
}
