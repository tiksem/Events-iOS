//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class CancelerSet {
    private var set:Set<Canceler> = []

    public init() {

    }

    public func add(canceler:Canceler, onCancelled:(() -> Void)? = nil) {
        set.insert(canceler)
        canceler.onCancelled = {
            self.set.remove(canceler)
            onCancelled?()
        }
    }

    public func cancelAll() {
        for canceler in set {
            canceler.cancel()
        }
    }

    deinit {
        cancelAll()
    }
}
