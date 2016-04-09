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
        cell.eventDate.text = EventUtils.eventDateToString(event.date)
    }
}

private let HeaderCellIdentifier = "EventsSectionHeaderCell"
private let PastEvents = "Past events"
private let UpcomingEvents = "Upcoming events"

class EventsAdapter : AzazaiListAdapter<EventsAdapterDelegate> {
    private var sectionsCount = 1
    private var loadedUpcomingEventsCount = -1

    init(controller viewController:UIViewController, eventsListView:UITableView, events: LazyList<Event, IOError>) {
        super.init(tableView: eventsListView,
                list: events,
                cellIdentifier: "EventCell",
                delegate: EventsAdapterDelegate(controller: viewController))
        
        UiUtils.registerNib(tableView: eventsListView, nibName: HeaderCellIdentifier, cellIdentifier: HeaderCellIdentifier)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sectionsCount == 1 ? list.count : loadedUpcomingEventsCount
        } else {
            return list.count - (loadedUpcomingEventsCount < 0 ? 0 : loadedUpcomingEventsCount)
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier(HeaderCellIdentifier) as! EventsSectionHeaderView
        header.headerText.text = getHeaderOfSection(section)
        return header
    }
    
    func getHeaderOfSection(section:Int) -> String {
        if section == 0 {
            if loadedUpcomingEventsCount == 0 {
                return PastEvents
            } else {
                return UpcomingEvents
            }
        } else {
            return PastEvents
        }
    }
    
    func onUpcomingEventsLoaded() {
        loadedUpcomingEventsCount = list.count - 1
        if (loadedUpcomingEventsCount != 0) {
            sectionsCount = 2
        }
    }

    override func listWillSet() {
        sectionsCount = 1
        loadedUpcomingEventsCount = -1
        super.listWillSet()
    }
}
