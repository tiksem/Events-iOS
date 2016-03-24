//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class EventsControllerWithSearchBar : EventsController {
    private var searchBar:AutoSearchBar! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UiUtils.viewFromNib("SearchBar") as! AutoSearchBar
        eventsView.eventsListView.tableHeaderView = searchBar
        searchBar.onSearchButtonClicked = search
        searchBar.onCancel = updateEvents
    }

    override func updateEvents() {
        var query:String? = searchBar.text
        if query == "" {
            query = nil
        }
        let events = requestManager.getEventsList(query, onArgsMerged: onArgsMerged)
        adapter.list = events
    }

    func search(text:String) {
        updateEvents()
    }
}
