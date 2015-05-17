//
//  Beacon.swift
//  OzuNav-ProjectParse
//
//  Created by A. Emre Ünal on 04/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
"beaconId" : 2,
"uuid" : "56E7C5F1-A20E-481E-AF24-24938D7C31A8",
"major" : 1,
"minor" : 1,
"designated" : false,
"yCoordinate" : 433,
"xCoordinate" : 433,
"hasLocationInfo" : false,
"displayName" : "",
*/

public class Beacon: Entity {
    let beaconId: Int
    let uuid: String
    let major: Int
    let minor: Int
    let designated: Bool
    let yCoordinate: Int
    let xCoordinate: Int
    let hasLocationInfo: Bool
    let displayName: String?
    let region: Region!

    init(beaconJson json:JSON, region:Region) {
        self.beaconId = json["beaconId"].intValue
        self.uuid = json["uuid"].stringValue
        self.major = json["major"].intValue
        self.minor = json["minor"].intValue

        self.designated = json["designated"].boolValue
        self.hasLocationInfo = json["hasLocationInfo"].boolValue

        self.xCoordinate = json["xCoordinate"].intValue
        self.yCoordinate = json["yCoordinate"].intValue

        let dispName = json["displayName"].stringValue
        if dispName == "" {
            self.displayName = nil
        } else {
            self.displayName = dispName
        }

        self.region = region
    }

    public var hashValue: Int { get { return id } }

    public var id: Int { get { return beaconId } }

    public func hasAttributes(#uuid:String, major:Int, minor:Int) -> Bool {
        if self.uuid == uuid && self.major == major && self.minor == minor {
            return true
        } else {
            return false
        }
    }
}

public func == (lhs: Beacon, rhs: Beacon) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
