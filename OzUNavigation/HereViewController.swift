//
//  HereViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 17/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit
import Kingfisher

private let IMAGE_SCALE_SIZE: CGFloat = 1.5

public class HereViewController : UIViewController, LocationUpdateListenerProtocol {
    private let beaconManager = BeaconManager.sharedInstance()

    private var currentRegion: Region?
    private var currentBeacon: Beacon?

    // Whether the image has been centered on the beacon
    private var imageAdjusted = false

    @IBOutlet weak var infoButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    @IBOutlet weak var labelBarView: UIView!
    @IBOutlet var unknownLocationLabels: [UILabel]!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    public override func viewDidLoad() {
        beaconManager.registerForLocationUpdates(self)
    }

    public override func viewDidAppear(animated: Bool) {
        askForLocationAuthorization()
        // Center image to Beacon if an image exists (an image exists if there is a region)
        if self.currentRegion != nil {
            self.centerImageToBeacon()
        }
    }

    private func askForLocationAuthorization() {
        switch beaconManager.locationAuthorizationStatus() {
        case .CanAsk:
            requestLocationAuthorization()
            // TODO Add different messages for different situations
        case .Authorized:
            beaconManager.startRangingBeacons()
        default:
            println("Not allowed")
        }
    }

    private func requestLocationAuthorization() {
        let alertController = UIAlertController(title: "Location Authorization", message: "In order to show you your current location and help you navigate, you must allow the use of Location Services. Would you like to allow?", preferredStyle: UIAlertControllerStyle.Alert)

        let allowAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            self.beaconManager.requestAuthorization()
        }
        alertController.addAction(allowAction)

        let disallowAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction!) in
            self.tabBarController!.selectedIndex = 0
            println("Didn't allow")
        }
        alertController.addAction(disallowAction)

        presentViewController(alertController, animated: true, completion: nil)
    }

    public func didEnterRegion(region:Region?, byDetectingBeacon detectedBeacon:Beacon?) {
        if region == nil { // Means that there are no detected beacons, which means no location
            eraseCurrentLocationInfo()
        } else {
            showDetailsOfRegion(region!, andBeacon: detectedBeacon!)
        }
    }

    private func eraseCurrentLocationInfo() {
        self.regionLabel.hidden = true
        self.beaconLabel.hidden = true
        self.labelBarView.hidden = true
        self.imageView.hidden = true
        self.currentBeacon = nil
        self.currentRegion = nil
        self.activityIndicator.startAnimating()
        for label in self.unknownLocationLabels {
            label.hidden = false
        }
    }

    private func showDetailsOfRegion(region:Region, andBeacon beacon:Beacon) {
        // Check if the current shown info is up-to-date
        if let lastRegion = currentRegion, lastBeacon = currentBeacon {
            if lastRegion == region && lastBeacon == beacon {
                if !imageAdjusted {
                    self.centerImageToBeacon()
                }
                return
            }
        }
        self.currentRegion = region
        self.currentBeacon = beacon
        setLabels()
        showImage()
        checkForLocationInfo()
    }

    private func centerImageToBeacon() {
        self.imageView.frame = CGRectMake(
            (CGFloat(-self.currentBeacon!.xCoordinate) / IMAGE_SCALE_SIZE) + (self.view.bounds.width / 2.0),
            (CGFloat(-self.currentBeacon!.yCoordinate) / IMAGE_SCALE_SIZE) + (self.view.bounds.height / 2.0),
            self.imageView.frame.size.width,
            self.imageView.frame.size.height);
        self.imageView.hidden = false

        self.activityIndicator.stopAnimating()
        imageAdjusted = true

        self.view.setNeedsDisplay()
        self.imageView.setNeedsDisplay()
    }

    private func setLabels() {
        self.labelBarView.hidden = false
        self.regionLabel.hidden = true
        self.beaconLabel.hidden = true
        for label in self.unknownLocationLabels {
            label.hidden = true
        }

        if let regionName = self.currentRegion!.displayName {
            self.regionLabel.text = regionName
            self.regionLabel.hidden = false
        }

        if let beaconName = self.currentBeacon!.displayName {
            self.beaconLabel.text = beaconName
            self.beaconLabel.hidden = false
        }
    }

    private func showImage() {
        let imageUrlPath = ServerDataManager.sharedInstance().getRegionImageUrl(self.currentRegion!.id)
        let imageUrl = NSURLComponents(string: imageUrlPath)!.URL!

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.imageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: nil) {
            (image, error, cacheType, imageURL) -> () in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.imageView.clipsToBounds = false
            self.scaleImage(image!)
            self.view.setNeedsDisplay()
            self.imageView.setNeedsDisplay()
        }
    }

    private func scaleImage(image:UIImage) {
        let size = CGSizeMake(image.size.width / IMAGE_SCALE_SIZE, image.size.height / IMAGE_SCALE_SIZE)
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageView.image = scaledImage
    }

    private func checkForLocationInfo() {
        if self.currentBeacon!.hasLocationInfo {
            self.infoButton.hidden = false
        } else {
            self.infoButton.hidden = true
        }
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoSegue" {
            let destination = segue.destinationViewController as! InfoViewController
            destination.beacon = self.currentBeacon!
        }
    }
}
