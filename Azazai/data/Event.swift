//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}

struct Event : Hashable, Equatable {
    let id:Int
    let name:String
    let description:String
    let userId:Int
    let address:String
    let peopleNumber:Int
    let subscribersCount:Int
    let date:Int
    let icon:Int
    let isPrivate:Bool

    init(_ map:Dictionary<String, AnyObject>) {
        id = Json.getInt(map, "id") ?? 0
        name = Json.getString(map, "name") ?? ""
        description = Json.getString(map, "description") ?? ""
        userId = Json.getInt(map, "userId") ?? 0
        address = Json.getString(map, "address") ?? ""
        peopleNumber = Json.getInt(map, "peopleNumber") ?? 0
        subscribersCount = Json.getInt(map, "subscribersCount") ?? 0
        date = Json.getInt(map, "date") ?? 0
        icon = Json.getInt(map, "icon") ?? 0
        isPrivate = Json.getBool(map, "isPrivate") ?? false
    }

    static func toEventsArray(array:[[String:AnyObject]]?) -> [Event]? {
        return try! array?.map {
            return Event($0)
        }
    }

    var hashValue: Int {
        return id.hashValue
    }
}
