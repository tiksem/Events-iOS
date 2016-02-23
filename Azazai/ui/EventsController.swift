//
//  EventsController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 12/25/15.
//  Copyright (c) 2015 Semyon Tikhonenko. All rights reserved.
//


import UIKit
import SwiftUtils

class EventsController: TableViewNibViewController {
    var eventsView:EventsView!
    let requestManager:RequestManager
    var adapter:EventsAdapter! = nil

    required init?(coder:NSCoder) {
        requestManager = RequestManager()
        super.init(coder: coder, nibFileName: "EventsView")
    }

    init() {
        requestManager = RequestManager()
        super.init(nibFileName: "EventsView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsView = nestedView as! EventsView
        adapter = createEventsAdapter()
    }

    func createEventsAdapter() -> EventsAdapter {
        return EventsAdapter(controller: self, eventsListView: eventsView.eventsListView,
                events: getEventsList())
    }

    func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getEventsList()
    }

    override func getTableView() -> UITableView? {
        return eventsView?.eventsListView
    }
}
