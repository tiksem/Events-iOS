//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: VkUser, rhs: VkUser) -> Bool {
    return lhs.id == rhs.id
}

struct VkUser : Hashable, Equatable {
    let id:Int
    let first_name:String
    let last_name:String
    let photo_200:String

    init(_ map:Dictionary<String, AnyObject>) {
        id = Json.getInt(map, "id") ?? 0
        first_name = Json.getString(map, "first_name") ?? ""
        last_name = Json.getString(map, "last_name") ?? ""
        photo_200 = Json.getString(map, "photo_200") ?? ""
    }

    static func toVkUsersArray(array:[[String:AnyObject]]?) -> [VkUser]? {
        return try! array?.map {
            return VkUser($0)
        }
    }

    var hashValue: Int {
        return id.hashValue
    }
}
