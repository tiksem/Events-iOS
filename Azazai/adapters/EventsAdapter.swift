//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class EventsAdapter {
    private weak var eventsListView: UITableView!
    private weak var controller:UIViewController!
    private let requestManager:RequestManager

    init() {
        requestManager = RequestManager()
    }

    func viewDidLoad(controller viewController:UIViewController, eventsListView:UITableView) {
        controller = viewController
        self.eventsListView = eventsListView

        let events = requestManager.getEventsList()
        events.onError = {
            Alerts.showOkAlert($0.description)
        }

        LazyListAdapter(cellIdentifier: "EventCell",
                nullCellIdentifier: "Loading",
                list: events,
                displayItem: displayEvent,
                displayNullItem: displayNull,
                onItemSelected: onEventSelected,
                tableView: eventsListView)

        eventsListView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func displayEvent(event:Event, cell:EventCell) {
        cell.eventName?.text = event.name
        cell.eventDescription?.text = event.description
        cell.layoutMargins = UIEdgeInsetsZero
        cell.peopleNumber?.text = String(event.subscribersCount) + "/" + String(event.peopleNumber)
    }

    func displayNull(cell:UITableViewCell) {
        UiUtils.removeSeparator(cell)
    }

    func onEventSelected(event:Event, position:Int) {
        controller.performSegueWithIdentifier("ShowEvent", sender: self)
    }
}
