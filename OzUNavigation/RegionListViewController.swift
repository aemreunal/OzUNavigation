//
//  RegionListViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

class RegionListViewController : UITableViewController {
    private var regionIds:[Int]!
    private var regionList:[String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let (regionIdsArray, regionListArray) = EntityManager.sharedInstance().getRegionsAsDisplayList()
        self.regionIds = regionIdsArray
        self.regionList = regionListArray
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showRegionImageSegue" {
            let selectedRow = self.tableView.indexPathForSelectedRow()!.row
            let destinationViewController = segue.destinationViewController as! RegionImageViewController
            let destinationRegionId = self.regionIds[selectedRow]
            destinationViewController.setRegionId(destinationRegionId)
            destinationViewController.title = EntityManager.sharedInstance().getRegion(ID: destinationRegionId).displayName
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("placesTableCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = regionList[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionList.count
    }
}
