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
    var controller:EventsAdapter!
    var eventsView:EventsView!

    required init?(coder:NSCoder) {
        super.init(coder: coder, nibFileName: "EventsView")
        controller = EventsAdapter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsView = nestedView as! EventsView
        controller.viewDidLoad(controller: self, eventsListView: eventsView.eventsListView)
    }
}
