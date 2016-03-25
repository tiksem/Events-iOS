//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class CalendarPickerController : PDTSimpleCalendarViewController {
    var selectedDateValue:NSDate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        UiUtils.setupCancelDoneButtonsOfNavigationBar(self, doneAction: "onDone", cancelAction: "onCancel")
        title = "Select event date"
        selectedDate = selectedDateValue
    }

    override var selectedDate:NSDate! {
        didSet {
            navigationItem.rightBarButtonItem!.enabled = selectedDate != nil
        }
    }

    func onDone() {
        let allEventsController = UiUtils.getBackViewControllerFromTabBarIfTabBarExists(self) as! AllEventsController
        allEventsController.onDateSelected(selectedDate!)
        onCancel()
    }

    func onCancel() {
        navigationController!.popViewControllerAnimated(true)
    }
}
