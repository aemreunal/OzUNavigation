//
//  LocationAuthorizationStatus.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 17/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation

public enum LocationAuthorizationStatus {
    /// Location Services are not enabled
    case NotEnabled

    /// Can ask for location use permission
    case CanAsk

    /// Not authorized to use location
    case NotAuthorized

    /// Authorized to use location
    case Authorized

    /// Bluetooth is not enabled
    case BluetoothDisabled
}
