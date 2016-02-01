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
    var controller:EventsAdapter!

    required init?(coder:NSCoder) {
        super.init(coder: coder)
        controller = EventsAdapter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        controller.viewDidLoad(controller: self, eventsListView: eventsListView)
    }
}
