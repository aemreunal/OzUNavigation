//
//  InfoViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 19/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit
import AFNetworking

public class InfoViewController: UIViewController {
    public var beacon:Beacon!

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UINavigationItem!

    override public func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setContent()
    }

    private func setTitle() {
        if let name = beacon.displayName {
            titleLabel.title = name
        }
    }

    private func setContent() {
        EntityManager.sharedInstance().getLocationInfoOfBeaconWithId(beacon.id, inRegionWithId: beacon.region.id) {
            (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
            if response is NSError {
                operation.responseData
                self.webView.loadHTMLString(operation.responseString, baseURL: operation.request.URL!)
            }
        }
    }

    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

//    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return self.webView
//    }
}
