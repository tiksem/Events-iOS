//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: __StructName__, rhs: __StructName__) -> Bool {
    return lhs.__key__ == rhs.__key__
}

struct __StructName__ : Hashable, Equatable {
    /*fields*/

    init(_ map:Dictionary<String, AnyObject>) {
        /*init*/
    }

    static func to__StructName__sArray(array:[[String:AnyObject]]?) -> [__StructName__]? {
        return try! array?.map {
            return __StructName__($0)
        }
    }

    var hashValue: Int {
        return __key__.hashValue
    }
}