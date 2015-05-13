//
//  Region.swift
//  OzuNav-ProjectParse
//
//  Created by A. Emre Ünal on 04/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
"regionId" : 2,
"displayName" : "some region\n",
"links" : [],
"regionWidth" : 1651,
"regionHeight" : 1275,
"lastUpdatedDate" : 1428757448000
*/

public class Region:Entity {
    let regionId:Int
    let displayName:String?
    let regionWidth:Int
    let regionHeight:Int
    let lastUpdatedDate:NSDate
    private(set) var connectedRegions = [(Region, Connection)]()

    init(regionJson json:JSON) {
        self.regionId = json["regionId"].intValue
        let dispName = json["displayName"].stringValue
        if dispName == "" {
            self.displayName = nil
        } else {
            self.displayName = dispName
        }
        self.regionWidth = json["regionWidth"].intValue
        self.regionHeight = json["regionHeight"].intValue
        let secondsSince1970:NSTimeInterval = (json["lastUpdatedDate"].doubleValue / 1000)
        self.lastUpdatedDate = NSDate(timeIntervalSince1970: secondsSince1970)
    }

    public func addConnection(toRegion region:Region, throughConnection connection:Connection) {
        connectedRegions.append((region, connection))
    }

    public func getConnection(toRegionWithID otherRegionId:Int) -> Connection? {
        for (region, connection) in connectedRegions {
            if region.regionId == otherRegionId {
                return connection
            }
        }
        return nil
    }

    public func getConnection(toRegion otherRegion:Region) -> Connection? {
        for (region, connection) in connectedRegions {
            if region == otherRegion {
                return connection
            }
        }
        return nil
    }

    public var hashValue: Int { get { return id } }

    public var id: Int { get { return regionId } }
}

public func == (lhs: Region, rhs: Region) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
