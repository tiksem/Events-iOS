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
        Network.getStringFromUrl("http://azazai.com/api/getEventsList?offset=0&limit=2", complete: {
            (response:String?, error:IOError?) in
            let info = response ?? error!.description
            Alerts.showOkAlert(info)
            print(info)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
