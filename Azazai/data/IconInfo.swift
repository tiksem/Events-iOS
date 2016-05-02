//
// Created by Semyon Tikhonenko on 2/21/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

func == (lhs: IconInfo, rhs: IconInfo) -> Bool {
    return lhs.key() == rhs.key()
}

struct IconInfo : Hashable, Equatable {
    let mediaId:Int
    let tag:String

    init(_ map:Dictionary<String, AnyObject>) {
        mediaId = Json.getInt(map, "mediaId") ?? 0
        tag = Json.getString(map, "tag") ?? ""
    }
    
    init(mediaId:Int, tag:String) {
        self.mediaId = mediaId
        self.tag = tag
    }

    static func toIconInfosArray(array:[[String:AnyObject]]?) -> [IconInfo]? {
        return try! array?.map {
            return IconInfo($0)
        }
    }
    
    func key() -> Int {
        return mediaId
    }
    
    var hashValue: Int {
        return key().hashValue
    }
}
