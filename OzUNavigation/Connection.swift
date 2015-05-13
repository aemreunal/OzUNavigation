//
//  Connection.swift
//  OzuNav-ProjectParse
//
//  Created by A. Emre Ünal on 04/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
"beacons" : [
14,
18
],
"connectionId" : 2
*/

public class Connection:Entity {
    let connectionId:Int
    let beacons:[Beacon]
    let regions:[Region]

    init(fromJson json:JSON) {
        self.connectionId = json["connectionId"].intValue

        var beaconList = [Beacon]()
        var regionList = [Region]()
        let entityManager = EntityManager.sharedInstance()
        for beaconIdJson in json["beacons"].arrayValue {
            let beaconId = beaconIdJson.intValue
            beaconList.append(entityManager.getBeacon(ID: beaconId))
            regionList.append(entityManager.getRegionOfBeacon(beaconID: beaconId))
        }
        self.beacons = beaconList
        self.regions = regionList
        connectRegions()
    }

    private func connectRegions() {
        // There are always two regions, since a connections connects two regions together,
        // therefore it is appropriate to use magic numbers
        regions[0].addConnection(toRegion: regions[1], throughConnection: self)
        regions[1].addConnection(toRegion: regions[0], throughConnection: self)
    }

    public func getOtherEndOfConnection(fromRegion: Region) -> Region {
        if fromRegion == regions[0] {
            return regions[1]
        } else {
            return regions[0]
        }
    }

    public var hashValue: Int { get { return id } }

    public var id: Int { get { return connectionId } }
}

public func == (lhs: Connection, rhs: Connection) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
