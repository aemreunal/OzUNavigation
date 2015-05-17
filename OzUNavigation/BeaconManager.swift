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

public class BeaconManager: NSObject, CLLocationManagerDelegate {
    // Singleton variable
    private static var instance: BeaconManager!

    // Location & Bluetooth
    private var locationManager: CLLocationManager!
    private let bluetoothManager = CBCentralManager()

    // Entity Manager
    private var entityManager = EntityManager.sharedInstance()

    // List of ranged beacon regions
    private var rangedBeaconRegions = [CLBeaconRegion]()

    // Whether authorization has been requested previously
    // TODO save this to UserDefaults
    private var locationAuthorizationHasBeenRequested = false

    class func sharedInstance() -> BeaconManager {
        self.instance = (self.instance ?? BeaconManager())
        return self.instance
    }

    public override init() {
        super.init()
        initLocationManager()
    }

    private func initLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager = locationManager
    }

    public func locationAuthorizationStatus() -> LocationAuthorizationStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return LocationAuthorizationStatus.NotEnabled
        } else if bluetoothManager.state != CBCentralManagerState.PoweredOn {
            return LocationAuthorizationStatus.BluetoothDisabled
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
        createRegions()
        for region in self.rangedBeaconRegions {
            self.locationManager.startRangingBeaconsInRegion(region)
            println("Started ranging region:\"\(region.identifier)\"")
        }
    }

    public func stopRangingBeacons() {
        for region in self.rangedBeaconRegions {
            self.locationManager.stopRangingBeaconsInRegion(region)
            println("Stopped ranging region:\"\(region.identifier)\"")
        }
    }

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        // if let rangedBeacon = beacons.first as? CLBeacon {
        //     if let beacon = entityManager.getBeaconBy(uuid: rangedBeacon.proximityUUID.UUIDString, major: rangedBeacon.major.integerValue, minor: rangedBeacon.minor.integerValue) {
        //         println("Nearest beacon has ID:\(beacon.id)")
        //     }
        // }
    }
}
