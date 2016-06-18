//
//  Timers.swift
//  Azazai
//
//  Created by Semyon Tikhonenko on 5/15/16.
//  Copyright © 2016 Semyon Tikhonenko. All rights reserved.
//

import Foundation

public class Timers {
    public static func executeAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

public class Loop {
    private let delay:Double
    private let action:()->Void
    private var stopped:Bool = false
    
    public init(delay:Double, action:()->Void) {
        self.delay = delay
        self.action = action
    }
    
    private func onTimer() {
        if !stopped {
            action()
            Timers.executeAfterDelay(delay, closure: {[weak self] in self?.onTimer()})
        }
    }
    
    public func start() {
        assert(!stopped)
        Timers.executeAfterDelay(delay, closure: {[weak self] in self?.onTimer()})
    }
    
    public func stop() {
        stopped = true
    }
    
    deinit {
        stop()
    }
}
