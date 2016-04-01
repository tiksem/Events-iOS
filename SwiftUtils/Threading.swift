//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public struct Threading {
    public static func runOnMainThread(callback:() -> Void) {
        if NSThread.isMainThread() {
            callback()
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), callback)
    }

    public static func runOnMainThreadIfNotCancelled(canceller:Canceler?, _ callback:() -> Void) {
        runOnMainThread {
            if canceller?.isCancelled ?? false {
                return
            }

            callback()
        }
    }

    public static func runOnBackground(backgroundTask:() -> Void, canceler:Canceler? = nil, onFinish:() -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            backgroundTask()
            runOnMainThreadIfNotCancelled(canceler, onFinish)
        })
    }
}
