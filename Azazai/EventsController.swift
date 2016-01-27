//
//  EventsController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 12/25/15.
//  Copyright (c) 2015 Semyon Tikhonenko. All rights reserved.
//


import UIKit
import SwiftUtils

class EventsController: UIViewController {
    @IBOutlet weak var eventsListView: UITableView!

    let requestManager:RequestManager

    required init?(coder aDecoder: NSCoder) {
        requestManager = RequestManager()
        super.init(coder: aDecoder);
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var events = requestManager.getEventsList()
        events.onError = {
            Alerts.showOkAlert($0.description)
        }

        var adapter = LazyListAdapter(cellIdentifier: "EventCell",
                nullCellIdentifier: "Loading",
                list: events,
                displayItem: displayEvent,
                onItemSelected: onEventSelected,
                tableView: eventsListView)

        eventsListView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayEvent(event:Event, cell:EventCell) {
        cell.eventName?.text = event.name
        cell.eventDescription?.text = event.description
        cell.peopleNumber?.text = String(event.subscribersCount) + "/" + String(event.peopleNumber)
    }

    func onEventSelected(event:Event, position:Int) {
        performSegueWithIdentifier("ShowEvent", sender: self)
    }
}
