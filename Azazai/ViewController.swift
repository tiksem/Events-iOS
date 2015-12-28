//
//  ViewController.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 12/25/15.
//  Copyright (c) 2015 Semyon Tikhonenko. All rights reserved.
//


import UIKit
import SwiftUtils

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var eventsListView: UITableView!

    let requestManager:RequestManager
    var events:[Event] = []

    required init?(coder aDecoder: NSCoder) {
        requestManager = RequestManager()
        super.init(coder: aDecoder);
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        requestManager.getEvents {
            (eventsList, error) in
            if let error = error {
                Alerts.showOkAlert(error.description)
                return
            }

            self.events = eventsList!
            self.eventsListView.dataSource = self
            self.eventsListView.delegate = self
            self.eventsListView.reloadData()
        }

        //eventsListView.registerClass(EventCell.self, forCellReuseIdentifier: "EventCell")
        eventsListView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventCell!
        let event = events[indexPath.row]
        cell.eventName?.text = event.name
        cell.eventDescription?.text = event.description
        cell.peopleNumber?.text = String(event.subscribersCount) + "/" + String(event.peopleNumber)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}
