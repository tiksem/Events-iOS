//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public struct Alerts {
    public static func showOkAlert(message:String? = nil, title:String? = nil, okButtonText:String = "OK") {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: okButtonText)
        alert.show()
    }
}
