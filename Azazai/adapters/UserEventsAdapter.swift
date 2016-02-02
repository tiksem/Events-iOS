//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class UserEventsAdapter : EventsAdapter {
    let mode:EventMode

    init(mode:EventMode) {
        self.mode = mode
    }

    override func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getUserEvents(mode)
    }
}
