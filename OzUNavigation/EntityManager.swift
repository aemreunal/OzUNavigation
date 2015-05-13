//
//  EntityStorage.swift
//  OzuNav-ProjectParse
//
//  Created by A. Emre Ünal on 04/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation
import SwiftyJSON
import AFNetworking

// Example: https://medium.com/@aommiez/afnetwork-integrate-swfit-80514b545b40
// Self-signed issue: https://github.com/Alamofire/Alamofire/issues/457

public class EntityManager {
    // Singleton variable
    private static var instance: EntityManager!

    // Entity objects
    private(set) var regions = [Int:Region]() // Map Region ID to Region
    private(set) var beacons = [Int:Beacon]() // Map Beacon ID to Beacon
    private(set) var connections = [Int:Connection]() // Map Connection ID to Connection

    private(set) var beaconsToRegions = [Int:Int]() // Map Beacon ID to Region ID
    private(set) var beaconsToConnections = [Int:[Connection]]() // Map Beacon ID to Connection

    // AFNetworking Manager
    let requestManager: AFHTTPRequestOperationManager

    // Server Data Manager
    let serverManager = ServerDataManager.sharedInstance()

    // Request operations
    private var regionRequestOperation:AFHTTPRequestOperation!
    private var beaconRequestOperations = [AFHTTPRequestOperation]()
    private var connectionRequestOperation:AFHTTPRequestOperation!
    private var beaconRequestOperationsComplete = 0

    // Load view
    private var loadScreenController:LoadViewProtocol!

    // Entity load status
    private var entitiesAreLoaded = false

    class func sharedInstance() -> EntityManager {
        self.instance = (self.instance ?? EntityManager())
        return self.instance
    }

    init() {
        self.requestManager = AFHTTPRequestOperationManager()
        requestManager.securityPolicy.allowInvalidCertificates = true
    }

    public func loadEntities(loadView:LoadViewProtocol) {
        self.loadScreenController = loadView
        if entitiesAreLoaded {
            loadingEntitiesDidComplete()
        } else {
            // Fill all the data structures, either by pulling them or loading them from storage
            self.createRegionRequest()
            self.regionRequestOperation.start()
        }
    }

    private func createRegionRequest() {
        let jsonUrlRequest = getJsonUrlRequest(url: serverManager.getRegionUrl())
        let request:AFHTTPRequestOperation = requestManager.HTTPRequestOperationWithRequest(jsonUrlRequest,
            success: handleRegionRequestSuccess,
            failure: handleRequestFailure)
        self.regionRequestOperation = request
        println("Region request job created.")
    }

    private func createBeaconRequests() {
        for (regionId:Int, _) in regions {
            let jsonUrlRequest = getJsonUrlRequest(url: serverManager.getBeaconUrl(regionId))
            let request:AFHTTPRequestOperation = requestManager.HTTPRequestOperationWithRequest(jsonUrlRequest,
                success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    self.handleBeaconRequestSuccess(operation, responseObject: responseObject, regionId: regionId)
                },
                failure: handleRequestFailure)
            request.addDependency(self.regionRequestOperation)
            self.beaconRequestOperations.append(request)
            println("Beacon request job for region \(regionId) created.")
        }
        println("All beacon request jobs created.")
    }

    private func createConnectionRequest() {
        let jsonUrlRequest = getJsonUrlRequest(url: serverManager.getConnectionUrl())

        let request:AFHTTPRequestOperation = requestManager.HTTPRequestOperationWithRequest(jsonUrlRequest,
            success: handleConnectionRequestSuccess,
            failure: handleRequestFailure)
//        for beaconRequest in beaconRequestOperations {
//            request.addDependency(beaconRequest)
//        }
        self.connectionRequestOperation = request
        println("Connection request job created.")
    }

    private func startBeaconRequests() {
        for request in beaconRequestOperations {
            request.start()
        }
        println("Beacon request jobs started.")
    }

    private func handleRegionRequestSuccess(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void {
        self.parseRegionJson(responseObject)
        println("Region request job complete.")
        self.createBeaconRequests()
        self.createConnectionRequest()
        self.startBeaconRequests()
    }

    private func handleBeaconRequestSuccess(operation: AFHTTPRequestOperation!, responseObject: AnyObject!, regionId:Int) {
        self.parseBeaconJson(responseObject, regionId: regionId)
        println("Beacon request job for region \(regionId) complete.")
        // Check for and start the connection request when the last Beacon request is complete.
        self.beaconRequestOperationsComplete++
        if self.beaconRequestOperationsComplete == self.beaconRequestOperations.count {
            self.connectionRequestOperation.start()
        }
    }

    private func handleConnectionRequestSuccess(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) {
        self.parseConnectionJson(responseObject)
        println("Connection request job complete.")
        loadingEntitiesDidComplete()
    }

    private func loadingEntitiesDidComplete() {
        self.entitiesAreLoaded = true
        self.loadScreenController.loadingEntitiesDidComplete()
    }

    private func handleRequestFailure(operation: AFHTTPRequestOperation!, error: NSError!) {
        println("'\(operation.request.URL!.relativePath!)' fetch error: " + error.localizedDescription)
    }

    private func parseRegionJson(jsonData: AnyObject) {
        let regionsJsonArray = JSON(jsonData)
        for (_, regionJson: JSON) in regionsJsonArray {
            let region:Region = Region(regionJson: regionJson)
            regions[region.regionId] = region
        }
    }

    private func parseBeaconJson(jsonData: AnyObject, regionId:Int) {
        let beaconsJsonArray = JSON(jsonData)
        for (_, beaconJson: JSON) in beaconsJsonArray {
            let beacon = Beacon(beaconJson: beaconJson)
            self.beacons[beacon.beaconId] = beacon
            self.beaconsToRegions[beacon.beaconId] = regionId
        }
    }

    private func parseConnectionJson(jsonData: AnyObject) {
        let connectionsJsonArray = JSON(jsonData)
        for (_, connectionJson: JSON) in connectionsJsonArray {
            let connection = Connection(fromJson: connectionJson)
            self.connections[connection.connectionId] = connection
            for beacon in connection.beacons {
                if var connectionsOfBeacon = self.beaconsToConnections[beacon.beaconId] {
                    connectionsOfBeacon.append(connection)
                } else {
                    self.beaconsToConnections[beacon.beaconId] = [connection]
                }

            }
        }
    }

    public func getRegion(ID id:Int) -> Region {
        return self.regions[id]!
    }

    public func getRegionOfBeacon(beaconID id:Int) -> Region {
        let regionId = self.beaconsToRegions[id]!
        return self.getRegion(ID: regionId)
    }

    public func getBeacon(ID id:Int) -> Beacon {
        return self.beacons[id]!
    }

    public func getConnection(ID id:Int) -> Connection {
        return self.connections[id]!
    }

    private func getJsonUrlRequest(#url: String) -> NSMutableURLRequest {
        return AFJSONRequestSerializer().requestWithMethod("POST", URLString: url, parameters: serverManager.getQueryAuthenticationJsonAsDict(), error: nil)
    }

    public func getRegionsAsDisplayList() -> ([Int], [String]) {
        let regionIds:[Int] = self.regions.keys.array
        var regionTableItems:[String] = [String]()

        for regionId in regionIds {
            let region = self.getRegion(ID: regionId)
            if let displayName = region.displayName {
                regionTableItems.append("\(displayName)")
            } else {
                regionTableItems.append("- (\(region.id))")
            }
        }

        return (regionIds, regionTableItems)
    }
}
