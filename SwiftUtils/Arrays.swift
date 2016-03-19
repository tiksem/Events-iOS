//
// Created by Semyon Tikhonenko on 3/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public extension Array {
    public var last:Generator.Element? {
        return count > 0 ? self[count - 1] : nil
    }

    func findFirst<L : BooleanType>(predicate: Element -> L) -> Element? {
        for item in self {
            if predicate(item) {
                return item // found
            }
        }
        return nil // not found
    }
}