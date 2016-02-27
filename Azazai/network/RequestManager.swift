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
                               args: [String: CustomStringConvertible]? = nil,
                               complete:([String: AnyObject]?, IOError?) -> Void,
                               onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonDictFromUrl(url, canceler: canceler, args: args, complete: complete)
        cancelers.add(canceler, onCancelled: onCancelled)
    }

    private func getInt(url:String, key:String,
                               args: [String: CustomStringConvertible]? = nil,
                               complete:(Int?, IOError?) -> Void,
                               onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonDictFromUrl(url, canceler: canceler, args: args, complete: {
            if let error = $1 {
                complete(nil, error)
            } else if let id = $0![key] as? Int {
                complete(id, nil)
            } else {
                complete(nil, IOError.ResponseError(error: "BackEndError", message: "\(key) key not found or invalid"))
            }
        })
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
    
    func getUserEvents(mod:EventMode, userId:Int) -> LazyList<Event, IOError> {
        let args:[String:CustomStringConvertible] = [
            "mod": mod,
            "userId": userId
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
    
    func getTags() -> LazyList<Tag, IOError> {
        let args:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getTags", key: "Tags", limit: 10, factory: {
            return Tag.toTagsArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
    func getEventsByTag(tag:String) -> LazyList<Event, IOError> {
        let args:[String:CustomStringConvertible] = [
            "tag": StringWrapper(tag)
        ]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getEventsByTag", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
    func getIcons() -> LazyList<IconInfo, IOError> {
        let args:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getIcons", key: "Icons", limit: 1000, factory: {
            return IconInfo.toIconInfosArray($0)!
        }, args: args, mergeArgs: mergeArgs)
    }
    
    func createEvent(args:[String:CustomStringConvertible],
                        onCancelled:(() -> Void)? = nil,
                        complete:(Int?, IOError?) -> Void) {
        getInt("http://azazai.com/api/createEvent", key: "id", args: args, complete: complete, onCancelled: onCancelled)
    }
    
}
