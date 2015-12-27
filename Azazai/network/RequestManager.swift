//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class RequestManager {
    func getEvents(callback:([Event]?, IOError?) -> Void) {
        Network.getJsonArrayFromUrl(
        "http://azazai.com/api/getEventsList?offset=0&limit=20",
                key: "events",
                complete: {
                    (response, error) in
                    var events:[Event]? = response != nil ? Event.toEventsArray(response!) : nil
                    callback(events, error)
                })
    }
}
