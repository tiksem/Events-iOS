//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public struct Threading {
    public static func runOnMainThread(callback:() -> Void) {
        dispatch_async(dispatch_get_main_queue(), callback)
    }
}
