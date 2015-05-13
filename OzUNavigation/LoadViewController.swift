//
//  LoadViewController.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 13/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit

public class LoadViewController : UIViewController, LoadViewProtocol {
    override public func viewDidLoad() {
        super.viewDidLoad()
        println("Load view appeared")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        EntityManager.sharedInstance().loadEntities(self)
    }

    public func loadingEntitiesDidComplete() {
        println("Load complete, about to perform segue")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        performSegueWithIdentifier("loadCompleteSegue", sender: self)
    }
}
