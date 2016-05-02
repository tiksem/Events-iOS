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
                             modifyPage: (([T], Canceler?, ([T]?, IOError?)->Void) -> Void)? = nil,
                             onArgsMerged:(()->Void)? = nil,
                             var args: [String: CustomStringConvertible] = [:],
                             var mergeArgs: [String: CustomStringConvertible] = [:],
                             offsetKey:String = "offset",
                             limitKey:String = "limit") -> LazyList<T, IOError> {
        var canceler = Canceler()
        cancelers.add(canceler)
        return Network.getJsonLazyList(url, key: key,
                                       limit: limit, factory: factory, modifyPage: modifyPage, args: args,
                                       offsetKey: offsetKey, limitKey: limitKey,
                                       mergeArgs: mergeArgs, onArgsMerged: onArgsMerged, canceler: canceler)
    }
    
    private func getLazyListWithTransformer<T, TransformType, FactoryType>(url:String,
                                            key:String,
                                            limit:Int = 10,
                                            factory: ([FactoryType]) -> [TransformType],
                                            modifyPage: (([TransformType], Canceler?, ([T]?, IOError?)->Void) -> Void),
                                            onArgsMerged:(()->Void)? = nil,
                                            var args: [String: CustomStringConvertible] = [:],
                                            var mergeArgs: [String: CustomStringConvertible] = [:],
                                            offsetKey:String = "offset",
                                            limitKey:String = "limit") -> LazyList<T, IOError> {
        var canceler = Canceler()
        cancelers.add(canceler)
        return Network.getJsonLazyListWithTransformer(url, key: key,
                                                      limit: limit, factory: factory, modifyPage: modifyPage, args: args,
                                                      offsetKey: offsetKey, limitKey: limitKey,
                                                      mergeArgs: mergeArgs, onArgsMerged: onArgsMerged, canceler: canceler)
    }
    
    func getEventsList(query query:String? = nil, dateFilter:Int? = nil, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Event, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        if let value = StringWrapper(query) { requestArgs["query"] = value }
        if let value = dateFilter { requestArgs["dateFilter"] = value }

        var mergeArgs:[String:CustomStringConvertible] = [:]
        mergeArgs["timeOut"] = true

        return getLazyList("http://azazai.com/api/getEventsList", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, modifyPage: nil, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getUserEvents(mod:EventMode, userId:Int, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Event, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["mod"] = mod
        requestArgs["userId"] = userId

        var mergeArgs:[String:CustomStringConvertible] = [:]
        mergeArgs["timeOut"] = true

        return getLazyList("http://azazai.com/api/getUserEvents", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, modifyPage: nil, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getTopComments(eventId:Int, maxCount:Int,
                        onCancelled:(() -> Void)? = nil,
                        complete:([Comment]?, IOError?) -> Void) {
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = eventId
        requestArgs["limit"] = maxCount

        getJsonArray("http://azazai.com/api/getCommentsList?offset=0", key: "Comments", args: requestArgs, complete: {
            complete(Comment.toCommentsArray($0), $1)
        }, onCancelled: onCancelled)
    }
    
    func getCommentsList(eventId:Int, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Comment, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = eventId

        var mergeArgs:[String:CustomStringConvertible] = [:]
        
        return getLazyList("http://azazai.com/api/getCommentsList", key: "Comments", limit: 10, factory: {
            return Comment.toCommentsArray($0)!
        }, modifyPage: fillCommentsUsers, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getTags(onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Tag, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        
        var mergeArgs:[String:CustomStringConvertible] = [:]
        
        return getLazyList("http://azazai.com/api/getTags", key: "Tags", limit: 10, factory: {
            return Tag.toTagsArray($0)!
        }, modifyPage: nil, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getEventsByTag(tag:String, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Event, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["tag"] = StringWrapper(tag)

        var mergeArgs:[String:CustomStringConvertible] = [:]
        mergeArgs["timeOut"] = true

        return getLazyList("http://azazai.com/api/getEventsByTag", key: "Events", limit: 10, factory: {
            return Event.toEventsArray($0)!
        }, modifyPage: nil, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func getIcons(onArgsMerged:(()->Void)? = nil)
                    -> LazyList<IconInfo, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        
        var mergeArgs:[String:CustomStringConvertible] = [:]
        
        return getLazyList("http://azazai.com/api/getIcons", key: "Icons", limit: 1000, factory: {
            return IconInfo.toIconInfosArray($0)!
        }, modifyPage: nil, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    
    func createEvent(args:[String:CustomStringConvertible],
                        onCancelled:(() -> Void)? = nil,
                        complete:(Int?, IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = args
        
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
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = id
        requestArgs["token"] = StringWrapper(token)

        Network.getJsonDictFromUrl("http://azazai.com/api/subscribe", canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
            
            complete(error)
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
    func cancelEvent(id:Int, token:String,
                        onCancelled:(() -> Void)? = nil,
                        complete:(IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = id
        requestArgs["token"] = StringWrapper(token)

        Network.getJsonDictFromUrl("http://azazai.com/api/cancelEvent", canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
            
            complete(error)
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
    func isSubscribed(id:Int, userId:Int,
                        onCancelled:(() -> Void)? = nil,
                        complete:(SubscribeStatus?, IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = id
        requestArgs["userId"] = userId

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
    
    func logoutFromVk(onCancelled:(() -> Void)? = nil,
                        complete:(IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        
        Network.getJsonDictFromUrl("http://api.vk.com/oauth/logout", canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
            self.clearVkData()
            complete(error)
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    
    func getAllRequests(id:Int, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<Request, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        requestArgs["id"] = id

        var mergeArgs:[String:CustomStringConvertible] = [:]
        
        return getLazyList("http://azazai.com/api/getAllRequests", key: "", limit: 10, factory: {
            return Request.toRequestsArray($0)!
        }, modifyPage: fillRequestsUsers, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    

    private func getUsersById(users:String? = nil,
                     success: ([VkUser])->Void,
                     error: ((NSError)->Void)? = nil,
                     canceler:Canceler? = nil,
                     cancelled: (()->Void)? = nil) {
        var args = [
                "fields": "photo_200"
        ]
        if let users = users {
            args["user_ids"] = users
        }

        let selectedCanceler = canceler ?? Canceler()
        if canceler == nil {
            cancelers.add(selectedCanceler)
        }

        let request = VKApi.users().get(args)
        request.executeWithResultBlock({
            (response:VKResponse!) in
            let json = response.json as! [[String:AnyObject]]
            success(VkUser.toVkUsersArray(json)!)
        }, errorBlock: {
            if let err = $0 {
                if let vkError = err.vkError where vkError.errorCode == Int(VK_API_CANCELED) {
                    cancelled?()
                } else {
                    error?(err)
                }
            }
        })

        selectedCanceler.body = request.cancel
    }

    func getUserById(userId:Int? = nil,
                     success: (VkUser)->Void,
                     error: ((NSError)->Void)? = nil,
                     canceler:Canceler? = nil,
                     cancelled: (()->Void)? = nil) {
        var users:String? = nil
        if let id = userId {
            users = String(id)
        }

        getUsersById(users, success: {
            success($0[0])
        }, error: error, canceler: canceler, cancelled: cancelled)
    }

    func getUsersByIdes(ides:[Int],
                        success: ([VkUser])->Void,
                        error: ((NSError)->Void)? = nil,
                        canceler:Canceler? = nil,
                        cancelled: (()->Void)? = nil) {
        let users = (try! ides.map {
            return String($0)
        }).joinWithSeparator(",")
        getUsersById(users, success: {
            (users) in
            if users.count != ides.count {
                var result:[VkUser] = []
                for id in ides {
                    result.append(users.findFirst({$0.id == id})!)
                }
                success(result)
            } else {
                success(users)
            }
        }, error: error, canceler: canceler, cancelled: cancelled)
    }

    func fillCommentsUsers(var comments:[Comment], canceler:Canceler? = nil, onFinish:([Comment]?, IOError?) -> Void) {
        getUsersByIdes(try! comments.map {$0.userId}, success: {
            (users) in
            for (commentIndex, user) in zip(0..<comments.count, users) {
                comments[commentIndex].user = user
            }
            onFinish(comments, nil)
            }, error: {
                onFinish(nil, IOError.NetworkError(error: $0))
            }, canceler: canceler)
    }

    func fillRequestsUsers(var requests:[Request], canceler:Canceler? = nil, onFinish:([Request]?, IOError?) -> Void) {
        getUsersByIdes(try! requests.map {$0.userId}, success: {
            (users) in
            for (requestIndex, user) in zip(0..<requests.count, users) {
                requests[requestIndex].user = user
            }
            onFinish(requests, nil)
            }, error: {
                onFinish(nil, IOError.NetworkError(error: $0))
            }, canceler: canceler)
    }
    
    func clearVkData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("VKAccessUserId")
        defaults.removeObjectForKey("VKAccessToken")
        defaults.removeObjectForKey("VKAccessTokenDate")
        defaults.synchronize()

        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies ?? [] {
            let domainName = cookie.domain
            let domainRange = domainName.rangeOfString("vk.com")

            if let range = domainRange where range.count > 0 {
                storage.deleteCookie(cookie)
            }
        }
    }
    
    func getSubscribers(eventId eventId:Int) -> LazyList<VkUser, IOError> {
        return getUsersUsingRequest("http://azazai.com/api/getSubscribers", key: "Subscribers",
                                    args: ["id":eventId as CustomStringConvertible])
    }
    
    func getRequests(eventId eventId:Int) -> LazyList<VkUser, IOError> {
        return getUsersUsingRequest("http://azazai.com/api/getRequests", key: "Requests",
                                    args: ["id":eventId as CustomStringConvertible])
    }
    
    func getUsersUsingRequest(url:String, key:String, args:[String:CustomStringConvertible]) -> LazyList<VkUser, IOError> {
        return getLazyListWithTransformer(url, key: key, factory: {
            (userIdes:[NSNumber]) -> [Int] in
                return userIdes.smap { Int($0.intValue) }
            },
            modifyPage: {
            (userIdes:[Int], canceler:Canceler?, complete:([VkUser]?, IOError?) -> Void) in
                self.getUsersByIdes(userIdes, success: {
                    (users) in
                    complete(users, nil)
                }, error: {
                    (err) in
                    complete(nil, IOError.NetworkError(error: err))
                })
        }, args:args)
    }
}
