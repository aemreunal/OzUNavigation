//
//  ServerDataManager.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation

public class ServerDataManager {
    // Singleton variable
    private static var instance: ServerDataManager!

    // Server details dictionary
    private var serverDataDict: [String:String]!
    // Server details dictionary keys
    private let serverIpAddressDictId = "serverIp"
    private let serverAddressDictId = "serverAddress"
    private let projectIdDictId = "projectId"
    private let projectSecretKeyDictId = "projectSecretKey"

    class func sharedInstance() -> ServerDataManager {
        self.instance = (self.instance ?? ServerDataManager())
        return self.instance
    }

    private init() {
        readServerDataPlist()
    }

    private func readServerDataPlist() {
        if let path = NSBundle.mainBundle().pathForResource("ServerData", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) as? [String:String] {
                serverDataDict = data
            }
        }
    }

    // Server info getters

    public func getServerIpAddress() -> String {
        return self.serverDataDict[serverIpAddressDictId]!
    }

    private func getServerAddress() -> String {
        return self.serverDataDict[serverAddressDictId]!
    }

    private func getProjectId() -> Int {
        return self.serverDataDict[projectIdDictId]!.toInt()!
    }

    private func getProjectSecretKey() -> String {
        return self.serverDataDict[projectSecretKeyDictId]!
    }

    public func getQueryAuthenticationJson() -> String {
        return "{\"projectId\":\(getProjectId()), \"secret\":\"\(getProjectSecretKey())\"}";
    }

    public func getQueryAuthenticationJsonAsDict() -> [String:AnyObject] {
        return [ "projectId" : getProjectId(), "secret" : getProjectSecretKey() ]
    }

    public func getQueryAuthenticationJsonAsNSData() -> NSData {
        let body:NSString = self.getRequestBodyString(fromString: getQueryAuthenticationJson())
        return NSData(base64EncodedString: body as String, options: NSDataBase64DecodingOptions.allZeros)!
    }

    func getRequestBodyString(fromString string: NSString) -> NSString {
        let plainData = string.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return base64String
    }

    // Query URL paths getters

    public func getProjectUrl() -> String {
        return getServerAddress() + "/project"
    }

    public func getRegionUrl() -> String {
        return getServerAddress() + "/regions"
    }

    public func getRegionImageUrl(regionId:Int) -> String {
        return getRegionUrl() + "/\(regionId)/image"
    }

    public func getBeaconUrl(regionId:Int) -> String {
        return getRegionUrl() + "/\(regionId)/beacons"
    }

    public func getConnectionUrl() -> String {
        return getServerAddress() + "/connections"
    }

    public func getConnectionImageUrl(connectionId:Int) -> String {
        return getConnectionUrl() + "/\(connectionId)/image"
    }
}
