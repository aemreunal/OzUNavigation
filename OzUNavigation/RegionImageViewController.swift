//
//  RegionImageViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit
import Kingfisher

// Proper image zooming via:
// https://github.com/evgenyneu/ios-imagescroll-swift

public class RegionImageViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!

    private var lastZoomScale: CGFloat = -1

    private var regionId:Int!
    private var imageUrl:NSURL!

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.maximumZoomScale = 6

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.imageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: nil) {
            (image, error, cacheType, imageURL) -> () in
            self.updateZoom()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }

    }

    public func setRegionId(regionId:Int) {
        self.regionId = regionId
        let imageUrlPath = "https://localhost:8443/robot/regions/\(regionId)/image"
        self.imageUrl = NSURLComponents(string: imageUrlPath)!.URL!
    }

    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(view.bounds.size.width / image.size.width,
                view.bounds.size.height / image.size.height)

            if minZoom > 1 {
                minZoom = 1
            }

            scrollView.minimumZoomScale = minZoom

            // Force scrollViewDidZoom fire if zoom did not change
            if minZoom == lastZoomScale {
                minZoom += 0.000001
            }

            scrollView.zoomScale = minZoom
            lastZoomScale = minZoom
        }
    }

    private func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height

            let viewWidth = view.bounds.size.width
            let viewHeight = view.bounds.size.height

            // Center image if it is smaller than screen
            var horizontalPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2.0
            if horizontalPadding < 0 {
                horizontalPadding = 0
            }

            var verticalPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2.0
            if verticalPadding < 0 {
                verticalPadding = 0
            }

            imageConstraintLeft.constant = horizontalPadding
            imageConstraintRight.constant = horizontalPadding

            imageConstraintTop.constant = verticalPadding
            imageConstraintBottom.constant = verticalPadding

            // Makes zoom out animation smooth and starting from the right point not from (0, 0)
            view.layoutIfNeeded()
        }
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
