//
// Created by Semyon Tikhonenko on 3/20/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class VkUtils {
    public static func logout() {
        let logoutUrl = "http://api.vk.com/oauth/logout"

        let request = NSMutableURLRequest(URL: NSURL(string: logoutUrl)!,
        cachePolicy:.ReloadIgnoringLocalCacheData,
        timeoutInterval:60.0)
        let responseData = try! NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
        let dict = try! SwiftUtils.Json.toDictionary(responseData)
        print(dict)

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("VKAccessUserId")
        defaults.removeObjectForKey("VKAccessToken")
        defaults.removeObjectForKey("VKAccessTokenDate")
        defaults.synchronize()
    }
}
