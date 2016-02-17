//
//  EventsController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 12/25/15.
//  Copyright (c) 2015 Semyon Tikhonenko. All rights reserved.
//


import UIKit
import SwiftUtils

class EventsController: NibViewController {
    var eventsView:EventsView!
    let requestManager:RequestManager

    required init?(coder:NSCoder) {
        requestManager = RequestManager()
        super.init(coder: coder, nibFileName: "EventsView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsView = nestedView as! EventsView
        createEventsAdapter()
    }

    func createEventsAdapter() -> EventsAdapter {
        return EventsAdapter(controller: self, eventsListView: eventsView.eventsListView,
                events: getEventsList())
    }

    func getEventsList() -> LazyList<Event, IOError> {
        return requestManager.getEventsList()
    }
}
