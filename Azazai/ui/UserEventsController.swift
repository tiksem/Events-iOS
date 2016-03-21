//
// Created by Semyon Tikhonenko on 2/17/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

private let SubscribedIndex = 1
private let CreatedIndex = 0

class MyEventsController: EventsController {
    var header:MyEventsHeaderView!
    
    func getEventsList(mode:EventMode) -> LazyList<Event, IOError> {
        return requestManager.getUserEvents(mode, userId: Int(VKSdk.accessToken().userId)!, onArgsMerged: onArgsMerged)
    }
    
    override func getEventsList() -> LazyList<Event, IOError> {
        return getEventsList(.Created)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header = UiUtils.viewFromNib("MyEventsHeaderView") as! MyEventsHeaderView
        header.tabs.addTarget(self, action: "onTabChanged", forControlEvents: .ValueChanged)
        eventsView.eventsListView.tableHeaderView = header

        let user = AppDelegate.get().user
        header.name.text = user.first_name + " " + user.last_name

        if let url = NSURL(string: user.photo_200) {
            header.avatar.sd_setImageWithURL(url)
        }

        let tap = UITapGestureRecognizer(target:self, action:"onLogout:")
        header.logoutButton.userInteractionEnabled = true
        header.logoutButton.addGestureRecognizer(tap)
    }
    
    func onTabChanged() {
        let index = header.tabs.selectedSegmentIndex
        let mode = index == SubscribedIndex ? EventMode.Subscribed : EventMode.Created
        let events = getEventsList(mode)
        adapter.list = events
        adapter.reloadData()
    }

    func onLogout(recognizer:UIGestureRecognizer) {
        var vc = self.presentingViewController
        while vc!.presentingViewController != nil {
            vc = vc!.presentingViewController
        }
        vc!.dismissViewControllerAnimated(true, completion:{
            UiUtils.postNotificationWithName("logout")
        })
    }
}
