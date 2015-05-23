//
//  BeaconManager.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 17/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

let LOCATION_RESET_TIME_SEC: Double = 3

public class BeaconManager: NSObject, CLLocationManagerDelegate {
    // Singleton variable
    private static var instance: BeaconManager!

    // Location & Bluetooth
    private var locationManager: CLLocationManager! // To monitor for beacon regions
    private var rangedBeaconRegions = [CLBeaconRegion]() // To store created beacon regions

    // Entity Manager
    private var entityManager = EntityManager.sharedInstance()

    // List of beacon region range listeners
    private var locationUpdateListeners = [LocationUpdateListenerProtocol]()
    private var locationUpdateTimer: NSTimer?

    // Whether regions are currently being listened to
    private(set) var listeningToRegions = false

    // Compass setting
    private var hereViewController: HereViewController!
    private(set) var shouldOrientToCompass = false

    class func sharedInstance() -> BeaconManager {
        self.instance = (self.instance ?? BeaconManager())
        return self.instance
    }

    public override init() {
        super.init()
        initLocationManager()
    }

    // CoreLocation-related functions

    private func initLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//        locationManager.distanceFilter = kCLHeadingFilterNone
        self.locationManager = locationManager
    }

    public func locationAuthorizationStatus() -> LocationAuthorizationStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return LocationAuthorizationStatus.NotEnabled
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedWhenInUse, .AuthorizedAlways:
                return LocationAuthorizationStatus.Authorized
            case .NotDetermined:
                return LocationAuthorizationStatus.CanAsk
            default:
                return LocationAuthorizationStatus.NotAuthorized
            }
        }
    }

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    // Beacons

    private func createRegions() {
        if !self.rangedBeaconRegions.isEmpty {
            return
        }
        var uuidList = Set<String>()
        for (_, beacon) in EntityManager.sharedInstance().beacons {
            uuidList.insert(beacon.uuid)
        }
        for uuid in uuidList {
            let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid), identifier: "Region for UUID:\(uuid)")
            self.rangedBeaconRegions.append(region)
            println("Createda region:\"\(region.identifier)\"")
        }
    }

    public func startRangingBeacons() {
        if listeningToRegions {
            return
        }
        createRegions()
        for region in self.rangedBeaconRegions {
            self.locationManager.startRangingBeaconsInRegion(region)
            println("Started ranging region:\"\(region.identifier)\"")
        }
        listeningToRegions = true
    }

    public func stopRangingBeacons() {
        if !listeningToRegions {
            return
        }
        for region in self.rangedBeaconRegions {
            self.locationManager.stopRangingBeaconsInRegion(region)
            println("Stopped ranging region:\"\(region.identifier)\"")
        }
        listeningToRegions = false
    }

    // Beacon updates

    public func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
         if let rangedBeacon = beacons.first as? CLBeacon {
             if let beacon = entityManager.getBeaconBy(uuid: rangedBeacon.proximityUUID.UUIDString, major: rangedBeacon.major.integerValue, minor: rangedBeacon.minor.integerValue) {
                println("Nearest beacon has ID:\(beacon.id), belongs to region with name:\(beacon.region.displayName!)")
                resetLocationTimer()
                notifyListenersOfLocationUpdate(beacon.region, beacon)
             }
         }
    }

    private func notifyListenersOfLocationUpdate(region:Region?, _ beacon: Beacon?) {
        self.locationUpdateListeners.map {
            (listener:LocationUpdateListenerProtocol) in
            listener.didEnterRegion(region, byDetectingBeacon: beacon)
        }
    }

    public func registerForLocationUpdates(listener: LocationUpdateListenerProtocol) -> Int {
        self.locationUpdateListeners.append(listener)
        return self.locationUpdateListeners.count - 1 // The index of the last appended listener
    }

    public func deregisterFromLocationUpdates(listenerQueueIndex: Int) {
        self.locationUpdateListeners.removeAtIndex(listenerQueueIndex)
    }

    private func resetLocationTimer() {
        if let currentTimer = self.locationUpdateTimer {
            currentTimer.invalidate()
        }
        self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(LOCATION_RESET_TIME_SEC, target: self, selector: "resetLocation:", userInfo: nil, repeats: true)
    }

    private func resetLocation(timer: NSTimer) {
        notifyListenersOfLocationUpdate(nil, nil)
        self.locationUpdateTimer?.invalidate()
    }

    // Compass updates
    public func toggleCompassForHere(hereViewController: HereViewController) {
        self.hereViewController = hereViewController
        shouldOrientToCompass = !shouldOrientToCompass
        if shouldOrientToCompass {
            locationManager.startUpdatingHeading()
        } else {
            locationManager.stopUpdatingHeading()
            hereViewController.rotateMap(0, animated: false)
        }
    }

    public func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        let rotation: Double = -newHeading.trueHeading * M_PI / 180.0
        hereViewController.rotateMap(rotation, animated: true)
    }
}
