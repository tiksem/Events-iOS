//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

struct Event {
    let id:Int
    let name:String
    let description:String
    let userId:Int
    let address:String
    let peopleNumber:Int
    let subscribersCount:Int
    let date:Int
    var isSubscribed:Bool = false

    init(_ map:Dictionary<String, AnyObject>) {
        id = Json.getInt(map, "id")!
        name = Json.getString(map, "name")!
        description = Json.getString(map, "description")!
        userId = Json.getInt(map, "userId")!
        address = Json.getString(map, "address")!
        peopleNumber = Json.getInt(map, "peopleNumber")!
        subscribersCount = Json.getInt(map, "subscribersCount")!
        date = Json.getInt(map, "date")!
    }

    public static func toEventsArray(array:[[String:AnyObject]]) -> [Event] {
        return try! array.map {
            return Event($0)
        }
    }
}
