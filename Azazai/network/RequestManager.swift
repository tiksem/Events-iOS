//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class RequestManager {
    private var cancelers:CancelerSet

    init() {
        cancelers = CancelerSet()
    }

    private func getDictionary(url:String,
                               complete:([String: AnyObject]?, IOError?) -> Void,
                               onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonDictFromUrl(url, canceler: canceler, complete: complete)
        cancelers.add(canceler, onCancelled: onCancelled)
    }

    private func getJsonArray(url:String,
                              key:String,
                              args: [String: CustomStringConvertible]? = nil,
                              complete:([[String: AnyObject]]?, IOError?) -> Void,
                              onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonArrayFromUrl(url, key: key, canceler: canceler, args: args, complete: complete)
        cancelers.add(canceler, onCancelled: onCancelled)
    }

    private func getLazyList<T>(url:String,
                                key:String,
                                limit:Int = 10,
                                factory: ([[String:AnyObject]]) -> [T],
                                var args: [String: CustomStringConvertible] = [:],
                                var mergeArgs: [String: CustomStringConvertible] = [:],
                                offsetKey:String = "offset",
                                limitKey:String = "limit") -> LazyList<T, IOError> {
        var canceler = Canceler()
        cancelers.add(canceler)
        return Network.getJsonLazyList(url, key: key,
                limit: limit, factory: factory, args: args,
                offsetKey: offsetKey, limitKey: limitKey,
                mergeArgs: mergeArgs, canceler: canceler)
    }
    
    func getEventsList() -> LazyList<Event, IOError> {
        let args:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getEventsList", key: "events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
    func getUserEvents(mod:EventMode) -> LazyList<Event, IOError> {
        let args:[String:CustomStringConvertible] = [
            "mod": mod
        ]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getUserEvents", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
    func getTopComments(eventId:Int, maxCount:Int,
                        onCancelled:(() -> Void)? = nil,
                        complete:([Comment]?, IOError?) -> Void) {
        let args:[String:CustomStringConvertible] = [
            "id": eventId,
            "limit": maxCount
        ]
        getJsonArray("http://azazai.com/api/getCommentsList?offset=0", key: "Comments", args: args, complete: {
            complete(Comment.toCommentsArray($0), $1)
        }, onCancelled: onCancelled)
    }
    
    func getCommentsList(eventId:Int) -> LazyList<Comment, IOError> {
        let args:[String:CustomStringConvertible] = [
            "id": eventId
        ]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getCommentsList", key: "Comments", limit: 10, factory: {
            return Comment.toCommentsArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
}
