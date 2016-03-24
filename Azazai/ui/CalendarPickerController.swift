//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class CalendarPickerController : PDTSimpleCalendarViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UiUtils.setupCancelDoneButtonsOfNavigationBar(self, doneAction: "onDone", cancelAction: "onCancel")
    }

    func onDone() {
        Alerts.showOkAlert("Done")
    }

    func onCancel() {
        navigationController!.popViewControllerAnimated(true)
    }
}
