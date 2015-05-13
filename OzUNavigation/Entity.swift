//
//  Entity.swift
//  OzuNav-AFNetworking
//
//  Created by A. Emre Ünal on 09/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation

/// Defines and Entity
protocol Entity: Hashable {
    /// The ID of the entity as defined by the iBeacon Server
    var id:Int { get }
}
