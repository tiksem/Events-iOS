//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: Request, rhs: Request) -> Bool {
    return lhs.key() == rhs.key()
}

struct Request : Hashable, Equatable {
    let userId:Int
    let event:Event
    var user:VkUser?

    init(_ map:Dictionary<String, AnyObject>) {
        userId = Json.getInt(map, "userId") ?? 0
        event = Event(Json.getDictionary(map, "event")!)
    }

    static func toRequestsArray(array:[[String:AnyObject]]?) -> [Request]? {
        return try! array?.map {
            return Request($0)
        }
    }
    
    func key() -> String {
        return (String(userId) + String(event.id))
    }
    
    var hashValue: Int {
        return (String(userId) + String(event.id)).hashValue
    }
}
