//
//  NavigationManager.swift
//  OzuNav-ProjectParse
//
//  Created by A. Emre Ünal on 05/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import Foundation

/*
Routes as an array of Int's: [<Source Region ID>, <Connection ID>, <Region ID>, <Connection ID>, ..., <Region ID>, <Connection ID>, <Destination Region ID>]
Even index == Region
Odd index == Connection

Compare distances by array sizes
*/

public class NavigationManager {
    // Singleton variable
    private static var instance: NavigationManager!

    // Entity Manager
    private let entityManager = EntityManager.sharedInstance()

    class func sharedInstance() -> NavigationManager {
        self.instance = (self.instance ?? NavigationManager())
        return self.instance
    }

    public func findRoute(fromRegionWithId sourceId:Int, toRegionWithId destinationId:Int) -> [Int]? {
        if sourceId == destinationId {
            return nil
        }
        let sourceRegion = entityManager.getRegion(ID: sourceId)
        let destinationRegion = entityManager.getRegion(ID: destinationId)
        return self.findRoute(fromRegion: sourceRegion, toRegion: destinationRegion)
    }

    public func findRoute(fromRegion source:Region, toRegion destination:Region) -> [Int]? {
        if source == destination {
            return nil
        }
        var paths = [Region:Connection]() // Region to last Connection to reach that region
        var visited = [Region:Bool]()
        var queue:[(Region, Connection!)] = [(source, nil)]

        while !queue.isEmpty {
            let (visitedRegion, connectionToRegion) = queue.removeAtIndex(0) // Pop the first element in the queue
            visited[visitedRegion] = true // Mark region as visited
            paths[visitedRegion] = connectionToRegion // Record the connection to region
            if visitedRegion == destination { // If current region is the destination
                break // We reached our destination by using the last connectionToRegion hop
            }
            addNeighborsOfRegion(visitedRegion, toQueue: &queue, visited: visited)
        }

        // Check whether the destination is reached (i.e. whether the path exists)
        let visitStatus = visited[destination]
        if visitStatus == nil || visitStatus! == false {
            return nil
        }
        return constructRoute(source, destination, paths)
    }

    private func addNeighborsOfRegion(region: Region, inout toQueue queue:[(Region, Connection!)], visited:[Region:Bool]) {
        for (neighborRegion, connectionToNeighbor) in region.connectedRegions { // Add all the neighbors of current region to the queue
            let visitStatus = visited[neighborRegion]
            if visitStatus == nil || visitStatus! == false { // Check whether the region is already visited, add if not
                let tuple:(Region, Connection!) = (neighborRegion, connectionToNeighbor) // Temp variable used as append bug workaround
                queue.append(tuple)
            }
        }
    }

    private func constructRoute(source:Region, _ destination: Region, _ paths:[Region:Connection]) -> [Int] {
        var route:[Int] = [destination.id]
        var currentRegion = destination
        while true {
            let connectionToPreviousRegion = paths[currentRegion]!
            let previousRegion = connectionToPreviousRegion.getOtherEndOfConnection(currentRegion)
            route.insert(connectionToPreviousRegion.id, atIndex: 0) // Insert connection ID to previous region
            route.insert(previousRegion.id, atIndex: 0) // Insert previous region ID
            if previousRegion == source {
                break
            } else {
                currentRegion = previousRegion
            }
        }
        return route
    }
}
