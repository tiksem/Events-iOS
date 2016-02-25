//
// Created by Semyon Tikhonenko on 2/25/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import Eureka

class AddEventController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Create New Event")
                <<< TextFloatLabelRow() {
            $0.title = "Event Name"
        }
    }
}
