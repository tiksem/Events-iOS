//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class Canceler : Hashable {
    public var body: (() -> Void)?
    public var onCancelled:(() -> Void)?

    private var cancelled:Bool = false
    public var isCancelled:Bool {
        get {
            assert(NSThread.isMainThread())
            return cancelled
        }
    }

    public init() {

    }

    public func cancel() {
        assert(NSThread.isMainThread())
        body?()
        cancelled = true
        onCancelled?()
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

public func == (lhs: Canceler, rhs: Canceler) -> Bool {
    return lhs === rhs
}
