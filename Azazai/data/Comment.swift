//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}

struct Comment : Hashable, Equatable {
    let id:Int
    let userId:Int
    let text:String
    let eventId:Int
    let date:Int
    var user:VkUser?

    init(_ map:Dictionary<String, AnyObject>) {
        id = Json.getInt(map, "id") ?? 0
        userId = Json.getInt(map, "userId") ?? 0
        text = Json.getString(map, "text") ?? ""
        eventId = Json.getInt(map, "eventId") ?? 0
        date = Json.getInt(map, "date") ?? 0
    }

    static func toCommentsArray(array:[[String:AnyObject]]?) -> [Comment]? {
        return try! array?.map {
            return Comment($0)
        }
    }

    var hashValue: Int {
        return id.hashValue
    }
}
