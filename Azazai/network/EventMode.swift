//
// Created by Semyon Tikhonenko on 2/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

enum EventMode : CustomStringConvertible {
    case Created, Subscribed

    var description: String {
        switch self {
            case .Created: return "created"
            case .Subscribed: return "subscribed"
        }
    }
}
