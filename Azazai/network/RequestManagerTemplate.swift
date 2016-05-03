//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import SwiftUtils

class RequestManagerTemplate {
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
    }/*helpers*/
    /*lazyList*/
    func __methodName__(__args__, onArgsMerged:(()->Void)? = nil)
                    -> LazyList<__ParamName__, IOError> {
        var requestArgs:[String:CustomStringConvertible] = [:]
        __request_args__
        var mergeArgs:[String:CustomStringConvertible] = [:]
        __merge_args__
        return getLazyList(__url__, key: __key__, limit: __limit__, factory: {
            return __ParamName__.to__ParamName__sArray($0)!
        }, modifyPage: __modifyPage__, onArgsMerged: onArgsMerged, args: requestArgs, mergeArgs: mergeArgs)
    }
    /*}*/

    /*array*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:([__ParamName__]?, IOError?) -> Void) {
        var requestArgs:[String:CustomStringConvertible] = [:]
        __request_args__
        getJsonArray(__url__, key: __key__, args: requestArgs, complete: {
            complete(__ParamName__.to__ParamName__sArray($0), $1)
        }, onCancelled: onCancelled)
    }
    /*}*/

    /*int*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:(__ParamName__?, IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        __request_args__
        Network.getJsonDictFromUrl(__url__, canceler: canceler, args: requestArgs, complete: {
            let key = __key__
            if let error = $1 {
                complete(nil, error)
            } else if let result = $0![key] as? __ParamName__ {
                complete(__result__, nil)
            } else {
                complete(nil, IOError.ResponseError(error: "BackEndError", message: "\(key) " +
                        "key not found or invalid"))
            }
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    /*}*/

    /*object*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:(__ParamName__?, IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        __request_args__
        Network.getJsonDictFromUrl(__url__, canceler: canceler, args: requestArgs, complete: {
            if let error = $1 {
                complete(nil, error)
            } else {
                let result = __ParamName__($0!)
                complete(__result__, nil)
            }
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    /*}*/

    /*void*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:(IOError?) -> Void) {
        var canceler = Canceler()
        var requestArgs:[String:CustomStringConvertible] = [:]
        __request_args__
        Network.getJsonDictFromUrl(__url__, canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
            /*body*/
            complete(error)
        })
        cancelers.add(canceler, onCancelled: onCancelled)
    }
    /*}*/

    /*helpersEnd*/
    /*BODY*/

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
