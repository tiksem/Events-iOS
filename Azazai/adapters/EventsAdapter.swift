//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class EventsAdapterDelegate : AzazaiAdapterDelegate<Event, EventCell> {
    init(controller:UIViewController) {
        super.init(hostController: controller, factory: {
            (event) in
            return EventController(event: event)
        })
    }

    override func displayItem(element event: Event, cell: CellType) -> Void {
        cell.eventName?.text = event.name
        cell.layoutMargins = UIEdgeInsetsZero
        EventUtils.displayPeopleNumberInLabel(cell.peopleNumber, event: event)
        EventUtils.displayIcon(event.icon, imageView: cell.icon)
        UiUtils.setupMultiLineForLabel(cell.eventDescription, text: event.description)
    }
}

class EventsAdapter : AzazaiListAdapter<EventsAdapterDelegate> {
    private var sectionsCount = 1
    private var loadedUpcomingEventsCount = 0

    init(controller viewController:UIViewController, eventsListView:UITableView, events: LazyList<Event, IOError>) {
        super.init(tableView: eventsListView,
                list: events,
                cellIdentifier: "EventCell",
                delegate: EventsAdapterDelegate(controller: viewController))
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sectionsCount == 1 ? list.count : loadedUpcomingEventsCount
        } else {
            return list.count - loadedUpcomingEventsCount
        }

        return list.count
    }

    func onUpcomingEventsLoaded() {
        sectionsCount = 2
        loadedUpcomingEventsCount = list.count - 1
    }

    func tableView(tableView:UITableView, titleForHeaderInSection section:NSInteger) -> String {
        if section == 1 {
            return "Past events"
        }

        return "Upcoming events"
    }

    override func listWillSet() {
        sectionsCount = 1
        loadedUpcomingEventsCount = 0
        super.listWillSet()
    }
}
