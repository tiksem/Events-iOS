//
// Created by Semyon Tikhonenko on 2/2/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils
import UIKit

class EventController : NibViewControllerWithoutHeightAdjustments {
    required init?(coder: NSCoder) {
        super.init(coder: coder, nibFileName: "EventView")
    }

    public init() {
        super.init(nibFileName: "EventView")
    }
}
