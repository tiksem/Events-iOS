//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: Tag, rhs: Tag) -> Bool {
    return lhs.key() == rhs.key()
}

struct Tag : Hashable, Equatable {
    let tagName:String
    let eventsCount:Int

    init(_ map:Dictionary<String, AnyObject>) {
        tagName = Json.getString(map, "tagName") ?? ""
        eventsCount = Json.getInt(map, "eventsCount") ?? 0
    }

    static func toTagsArray(array:[[String:AnyObject]]?) -> [Tag]? {
        return try! array?.map {
            return Tag($0)
        }
    }
    
    func key() -> String {
        return tagName
    }
    
    var hashValue: Int {
        return tagName.hashValue
    }
}
