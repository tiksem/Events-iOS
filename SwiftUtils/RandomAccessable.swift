//
// Created by Semyon Tikhonenko on 1/1/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public protocol RandomAccessable {
    typealias ItemType
    subscript (index:Int) -> ItemType? { get }
    var count:Int { get }
}
