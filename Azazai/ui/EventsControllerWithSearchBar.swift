//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class EventsControllerWithSearchBar : EventsController {
    private var searchBar:AutoSearchBar! = nil
    var searchBarView:SearchBarView! = nil
    private var dateFilterHeight:CGFloat = 0
    var selectedDate:NSDate? = nil

    func showCalendarFilter() {
        searchBarView.dateFilterHeight.constant = dateFilterHeight
        searchBarView.frame.size.height = searchBar.frame.height + dateFilterHeight
        searchBarView.closeDateFilter.hidden = false
        eventsView.eventsListView.reloadData()
    }

    func hideCalendarFilter() {
        searchBarView.dateFilterHeight.constant = 0
        searchBarView.frame.size.height = searchBar.frame.height
        searchBarView.closeDateFilter.hidden = true
        eventsView.eventsListView.reloadData()
    }

    func onAfterSearchBar() {
        hideCalendarFilter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarView = UiUtils.viewFromNib("SearchBar") as! SearchBarView
        eventsView.eventsListView.tableHeaderView = searchBarView
        searchBar = searchBarView.searchbar
        searchBar.onSearchButtonClicked = search
        searchBar.onCancel = updateEvents
        dateFilterHeight = searchBarView.dateFilterHeight.constant
        onAfterSearchBar()
    }

    override func updateEvents() {
        var query:String? = searchBar.text
        if query == "" {
            query = nil
        }
        
        var date:Int? = nil
        if let interval = selectedDate?.timeIntervalSince1970 {
            date = Int(interval)
        }
        
        let events = requestManager.getEventsList(query: query, dateFilter: date, onArgsMerged: onArgsMerged)
        adapter.list = events
    }

    func search(text:String) {
        updateEvents()
    }
}
