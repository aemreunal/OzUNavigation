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

    // Compass rotation calculations
    private var mapCenterScaled: CGPoint!
    private var beaconCoorScaled: CGPoint!

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var compassButton: UIButton!

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
        LocationAuthorizationHelper.askForLocationAuthorization(self.tabBarController!)
        // Center image to Beacon if an image exists (an image exists if there is a region)
        if self.currentRegion != nil {
            self.centerImageToBeacon()
        }
    }

    public override func viewWillDisappear(animated: Bool) {
        if beaconManager.shouldOrientToCompass { // If compass orientation is currently on
            beaconManager.toggleCompassForHere(self)
            eraseCurrentLocationInfo()
        }
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
        self.imageAdjusted = false
        // Compass calculation
        self.mapCenterScaled = CGPoint(x: (CGFloat(region.regionWidth) / 2.0) / IMAGE_SCALE_SIZE, y: (CGFloat(region.regionHeight) / 2.0) / IMAGE_SCALE_SIZE)
        self.beaconCoorScaled = CGPoint(x: CGFloat(beacon.xCoordinate) / IMAGE_SCALE_SIZE, y: CGFloat(beacon.yCoordinate) / IMAGE_SCALE_SIZE)
        setLabels()
        showImage()
        checkForLocationInfo()
        self.centerImageToBeacon()
    }

    private func centerImageToBeacon() {
        if self.imageView.image == nil {
            return
        }
        self.imageView.frame = CGRectMake(
            (CGFloat(-self.currentBeacon!.xCoordinate) / IMAGE_SCALE_SIZE) + (self.view.bounds.width / 2.0),
            (CGFloat(-self.currentBeacon!.yCoordinate) / IMAGE_SCALE_SIZE) + (self.view.bounds.height / 2.0),
            self.imageView.frame.size.width,
            self.imageView.frame.size.height)
        self.imageView.hidden = false

        self.activityIndicator.stopAnimating()
        self.imageAdjusted = true

        // Refresh views
        self.view.setNeedsDisplay()
        self.imageView.setNeedsDisplay()
    }

    private func setLabels() {
        self.labelBarView.hidden = false
        for label in self.unknownLocationLabels {
            label.hidden = true
        }

        self.regionLabel.hidden = true
        if let regionName = self.currentRegion!.displayName {
            self.regionLabel.text = regionName
            self.regionLabel.hidden = false
        }

        self.beaconLabel.hidden = true
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
            // Refresh views
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
    @IBAction func compassButtonTapped(sender: UIButton) {
        beaconManager.toggleCompassForHere(self)
        if beaconManager.shouldOrientToCompass {
            compassButton.backgroundColor = UIColor(white: 1, alpha: 0.3)
        } else {
             compassButton.backgroundColor = nil
        }
    }

    public func rotateMap(rotation: Double, animated:Bool) {
        if animated {
            UIView.animateWithDuration(0.15) {
                self.setRotation(rotation)
            }
        } else {
            self.setRotation(rotation)
        }
    }

    private func setRotation(rotation: Double) {
        self.imageView.transform = self.CGAffineTransformMakeRotationOf(
            CGFloat(rotation),
            aroundPoint: CGPoint(
                x: self.beaconCoorScaled.x - self.mapCenterScaled.x,
                y: self.beaconCoorScaled.y - self.mapCenterScaled.y
            )
        )
    }

    /// The point represents the deviation from the center point of the image.
    ///
    /// For a 100x100 image:
    ///
    /// CGPoint(x = -50, y = -50) -> image will be rotated from the left top
    ///
    /// CGPoint(x = 50, y = 50) -> image will be rotated from the right bottom
    private func CGAffineTransformMakeRotationOf(angle: CGFloat, aroundPoint pt: CGPoint) -> CGAffineTransform {
        let fx: CGFloat = pt.x
        let fy: CGFloat = pt.y
        let fcos: CGFloat = cos(angle)
        let fsin: CGFloat = sin(angle)
        return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos)
    }
}
