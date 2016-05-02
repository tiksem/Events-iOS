//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: VkUser, rhs: VkUser) -> Bool {
    return lhs.key() == rhs.key()
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
    
    init(id:Int, first_name:String, last_name:String, photo_200:String) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.photo_200 = photo_200
    }

    static func toVkUsersArray(array:[[String:AnyObject]]?) -> [VkUser]? {
        return try! array?.map {
            return VkUser($0)
        }
    }
    
    func key() -> Int {
        return id
    }
    
    var hashValue: Int {
        return key().hashValue
    }
}
