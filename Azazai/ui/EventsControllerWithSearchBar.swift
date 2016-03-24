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

        let calendarButton = UIBarButtonItem(image:UIImage(named: "calendar"),
        style:.Plain, target:self, action:Selector("onCalendarTap"))

        let topViewController = navigationController!.topViewController!
        topViewController.navigationItem.setLeftBarButtonItem(calendarButton, animated: false)
    }

    func onCalendarTap() {
        let calendarController = CalendarPickerController()
        navigationController!.pushViewController(calendarController, animated: true)
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
