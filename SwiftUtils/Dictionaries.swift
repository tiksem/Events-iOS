//
// Created by Semyon Tikhonenko on 1/26/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

func +=<U,T>(inout lhs: [U:T], rhs: [U:T]) {
    for (key, value) in rhs {
        lhs[key] = value
    }
}