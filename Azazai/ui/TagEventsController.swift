//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class TagEventsController : EventsControllerWithSearchBar {
    private let tag:String

    required init?(coder:NSCoder) {
        assertionFailure("Should not be called")
        self.tag = ""
        super.init(coder: coder)
    }

    init(tag:String) {
        self.tag = tag
        super.init()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "\(tag) Events"
    }

    override func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getEventsByTag(tag, onArgsMerged: onArgsMerged)
    }

    override func getTableView() -> UITableView? {
        return nil
    }
}
