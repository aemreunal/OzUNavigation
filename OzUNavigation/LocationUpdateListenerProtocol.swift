//
//  RegionDetectionListenerProtocol.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 18/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation

public protocol LocationUpdateListenerProtocol {
    func didEnterRegion(region:Region?, byDetectingBeacon detectedBeacon:Beacon?)
}
