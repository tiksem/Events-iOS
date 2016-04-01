//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit
import SwiftUtils

class AllEventsController : EventsControllerWithSearchBar {
    var topController:UIViewController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        topController = navigationController!.topViewController!

        let tap = UITapGestureRecognizer(target:self, action:#selector(AllEventsController.onCloseDateFilter(_:)))
        searchBarView.closeDateFilter.userInteractionEnabled = true
        searchBarView.closeDateFilter.addGestureRecognizer(tap)
    }

    func onCalendarTap() {
        let calendarController = CalendarPickerController()
        calendarController.selectedDateValue = selectedDate
        calendarController.weekdayHeaderEnabled = true
        calendarController.weekdayTextType = .VeryShort
        calendarController.edgesForExtendedLayout = .None
        navigationController!.pushViewController(calendarController, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Events"

        let calendarButton = UIBarButtonItem(image:UIImage(named: "calendar"),
                style:.Plain, target:self, action:#selector(AllEventsController.onCalendarTap))

        topController.navigationItem.setLeftBarButtonItem(calendarButton, animated: animated)
    }

    func onDateSelected(date:NSDate) {
        selectedDate = date
        searchBarView.dateFilter?.text = "Date filter: " + DateUtils.getAlternativeDisplayDate(date)
        showCalendarFilter()
        updateEvents()
    }

    func onCloseDateFilter(recognizer:UIGestureRecognizer) {
        hideCalendarFilter()
        selectedDate = nil
        updateEvents()
    }
}
