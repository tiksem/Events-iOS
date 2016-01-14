//
// Created by Semyon Tikhonenko on 1/14/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

struct Comment {
    let userId:Int
    let text:String
    let eventId:Int
    let date:Int

    init(_ map:Dictionary<String, AnyObject>) {
        userId = Json.getInt(map, "userId") ?? 0
        text = Json.getString(map, "text") ?? ""
        eventId = Json.getInt(map, "eventId") ?? 0
        date = Json.getInt(map, "date") ?? 0
    }

    public static func toCommentsArray(array:[[String:AnyObject]]?) -> [Comment]? {
        return try! array?.map {
            return Comment($0)
        }
    }
}
