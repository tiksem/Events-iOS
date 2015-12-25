//
//  ViewController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 12/25/15.
//  Copyright (c) 2015 Semyon Tikhonenko. All rights reserved.
//


import UIKit
import SwiftUtils

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Network.getJsonArrayFromUrl(
        "http://azazai.com/api/getEventsList?offset=0&limit=2",
                key: "events",
                complete: {
            (response:[[String:AnyObject]]?, error:IOError?) in
            if let error = error {
                Alerts.showOkAlert(error.description)
            } else {
                var events = Event.toEventsArray(response!)
                Alerts.showOkAlert(String(events[0].name))
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
