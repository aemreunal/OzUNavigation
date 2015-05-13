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
    let beaconId: Int // : 2,
    let uuid: String // :  //56E7C5F1-A20E-481E-AF24-24938D7C31A8 //,
    let major: Int // : 1,
    let minor: Int // : 1,
    let designated: Bool // : false,
    let yCoordinate: Int // : 433,
    let xCoordinate: Int // : 433,
    let hasLocationInfo: Bool // : false,
    let displayName: String? // :  //,

    init(beaconJson json:JSON) {
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
    }

    public var hashValue: Int { get { return id } }

    public var id: Int { get { return beaconId } }
}

public func == (lhs: Beacon, rhs: Beacon) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
