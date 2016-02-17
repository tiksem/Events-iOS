//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class MyEventsController : EventsController {
    override func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getUserEvents(.Created, token: VKSdk.accessToken().accessToken)
    }
}
