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
        cell.eventDescription?.text = event.description
        cell.layoutMargins = UIEdgeInsetsZero
        EventUtils.displayPeopleNumberInLabel(cell.peopleNumber, event: event)
        EventUtils.displayIcon(event.icon, imageView: cell.icon)
    }
}

class EventsAdapter : AzazaiListAdapter<EventsAdapterDelegate> {
    init(controller viewController:UIViewController, eventsListView:UITableView, events: LazyList<Event, IOError>) {
        super.init(tableView: eventsListView,
                list: events,
                cellIdentifier: "EventCell",
                delegate: EventsAdapterDelegate(controller: viewController))
    }
}
