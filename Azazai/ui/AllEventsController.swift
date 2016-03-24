//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

class AllEventsController : EventsControllerWithSearchBar {
    var topController:UIViewController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        topController = navigationController!.topViewController!
    }


    func onCalendarTap() {
        let calendarController = CalendarPickerController()
        //calendarController.selectedDateValue = DateUtils.createNSDate(year: 2016, month: 3, day: 25)
        calendarController.weekdayHeaderEnabled = true
        calendarController.weekdayTextType = .VeryShort
        calendarController.edgesForExtendedLayout = .None
        navigationController!.pushViewController(calendarController, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Events"

        let calendarButton = UIBarButtonItem(image:UIImage(named: "calendar"),
                style:.Plain, target:self, action:Selector("onCalendarTap"))

        topController.navigationItem.setLeftBarButtonItem(calendarButton, animated: animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        topController.navigationItem.setLeftBarButtonItem(nil, animated: animated)
    }

}
