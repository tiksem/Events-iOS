//
//  Maps.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 4/7/16.
//  Copyright © 2016 Semyon Tikhonenko. All rights reserved.
//

import Foundation
import UIKit

public class Maps {
    public static func startAppleMapsSearch(query:String) {
        if let query = query.stringByAddingPercentEncodingForURLQueryValue() {
            if let url = NSURL(string: "http://maps.apple.com/?q=" + query) {
                let app = UIApplication.sharedApplication()
                app.openURL(url)
            }
        }
    }
}
