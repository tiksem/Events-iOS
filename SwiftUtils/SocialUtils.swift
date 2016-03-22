//
// Created by Semyon Tikhonenko on 3/22/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class SocialUtils {
    public static func openVkProfile(userId:String) {
        let url = NSURL(string: "vk://vk.com/id" + userId)!
        let app = UIApplication.sharedApplication()
        if app.canOpenURL(url) {
            app.openURL(url)
        } else {
            app.openURL(NSURL(string: "http://vk.com/id" + userId)!)
        }
    }
}
