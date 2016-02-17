//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class EventsAdapterDelegate : AdapterDelegateDefaultImpl<Event, EventCell> {
    private unowned let controller:UIViewController

    init(controller:UIViewController) {
        self.controller = controller
        super.init()
    }

    override func displayItem(element event: T, cell: CellType) -> Void {
        cell.eventName?.text = event.name
        cell.eventDescription?.text = event.description
        cell.layoutMargins = UIEdgeInsetsZero
        cell.peopleNumber?.text = String(event.subscribersCount) + "/" + String(event.peopleNumber)
    }

    override func onItemSelected(element element: T, position: Int) -> Void {
        controller.performSegueWithIdentifier("ShowEvent", sender: self)
    }
}

class EventsAdapter : LazyListAdapter<EventsAdapterDelegate, IOError> {
    private weak var eventsListView: UITableView!

    init(controller viewController:UIViewController, eventsListView:UITableView, events: LazyList<Event, IOError>) {
        super.init(cellIdentifier: "EventCell",
                nullCellIdentifier: "Loading",
                list: events,
                tableView: eventsListView,
                delegate: EventsAdapterDelegate(controller: viewController))
        events.onError = {
            Alerts.showOkAlert($0.description)
        }
    }
}
