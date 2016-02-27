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
        let requestArgs:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getEventsList", key: "events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getUserEvents(mod:EventMode, userId:Int) -> LazyList<Event, IOError> {
        let requestArgs:[String:CustomStringConvertible] = [
            "mod": mod,
            "userId": userId
        ]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getUserEvents", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getTopComments(eventId:Int, maxCount:Int,
                        onCancelled:(() -> Void)? = nil,
                        complete:([Comment]?, IOError?) -> Void) {
        let requestArgs:[String:CustomStringConvertible] = [
            "id": eventId,
            "limit": maxCount
        ]
        getJsonArray("http://azazai.com/api/getCommentsList?offset=0", key: "Comments", args: requestArgs, complete: {
            complete(Comment.toCommentsArray($0), $1)
        }, onCancelled: onCancelled)
    }
    
    func getCommentsList(eventId:Int) -> LazyList<Comment, IOError> {
        let requestArgs:[String:CustomStringConvertible] = [
            "id": eventId
        ]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getCommentsList", key: "Comments", limit: 10, factory: {
            return Comment.toCommentsArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getTags() -> LazyList<Tag, IOError> {
        let requestArgs:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getTags", key: "Tags", limit: 10, factory: {
            return Tag.toTagsArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getEventsByTag(tag:String) -> LazyList<Event, IOError> {
        let requestArgs:[String:CustomStringConvertible] = [
            "tag": StringWrapper(tag)
        ]
        let mergeArgs:[String:CustomStringConvertible] = [
            "timeOut": true
        ]
        return getLazyList("http://azazai.com/api/getEventsByTag", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getIcons() -> LazyList<IconInfo, IOError> {
        let requestArgs:[String:CustomStringConvertible] = [:]
        let mergeArgs:[String:CustomStringConvertible] = [:]
        return getLazyList("http://azazai.com/api/getIcons", key: "Icons", limit: 1000, factory: {
            return IconInfo.toIconInfosArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func createEvent(args:[String:CustomStringConvertible],
                        onCancelled:(() -> Void)? = nil,
                        complete:(Int?, IOError?) -> Void) {
        var canceler = Canceler()
        let requestArgs:[String:CustomStringConvertible] = args
        Network.getJsonDictFromUrl("http://azazai.com/api/createEvent", canceler: canceler, args: requestArgs, complete: {
            let key = "id"
            if let error = $1 {
                complete(nil, error)
            } else if let result = $0![key] as? Int {
                complete(result, nil)
            } else {
                complete(nil, IOError.ResponseError(error: "BackEndError", message: "\(key) " +
                        "key not found or invalid"))
            }
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
    func subscribe(id:Int, token:String,
                        onCancelled:(() -> Void)? = nil,
                        complete:(IOError?) -> Void) {
        var canceler = Canceler()
        let requestArgs:[String:CustomStringConvertible] = [
            "id": id,
            "token": StringWrapper(token)
        ]
        Network.getJsonDictFromUrl("http://azazai.com/api/subscribe", canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
            complete(error)
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
    func isSubscribed(id:Int, userId:Int,
                        onCancelled:(() -> Void)? = nil,
                        complete:(SubscribeStatus?, IOError?) -> Void) {
        var canceler = Canceler()
        let requestArgs:[String:CustomStringConvertible] = [
            "id": id,
            "userId": userId
        ]
        Network.getJsonDictFromUrl("http://azazai.com/api/isSubscribed", canceler: canceler, args: requestArgs, complete: {
            let key = "isSubscribed"
            if let error = $1 {
                complete(nil, error)
            } else if let result = $0![key] as? String {
                complete(SubscribeStatus(rawValue: result), nil)
            } else {
                complete(nil, IOError.ResponseError(error: "BackEndError", message: "\(key) " +
                        "key not found or invalid"))
            }
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
}
