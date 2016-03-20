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
                                modifyPage: (([T], Canceler?, ([T])->Void) -> Void)? = nil,
                                var args: [String: CustomStringConvertible] = [:],
                                var mergeArgs: [String: CustomStringConvertible] = [:],
                                offsetKey:String = "offset",
                                limitKey:String = "limit") -> LazyList<T, IOError> {
        var canceler = Canceler()
        cancelers.add(canceler)
        return Network.getJsonLazyList(url, key: key,
                limit: limit, factory: factory, modifyPage: modifyPage, args: args,
                offsetKey: offsetKey, limitKey: limitKey,
                mergeArgs: mergeArgs, canceler: canceler)
    }/*helpers*/
    /*lazyList*/
    func __methodName__(__args__, modifyPage:(([__ParamName__], Canceler?, ([__ParamName__])->Void) -> Void)? = nil)
                    -> LazyList<__ParamName__, IOError> {
        let requestArgs:[String:CustomStringConvertible] = __request_args__
        let mergeArgs:[String:CustomStringConvertible] = __merge_args__
        return getLazyList(__url__, key: __key__, limit: __limit__, factory: {
            return __ParamName__.to__ParamName__sArray($0)!
        }, modifyPage: modifyPage, args: requestArgs, mergeArgs: mergeArgs)
    }
    /*}*/

    /*array*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:([__ParamName__]?, IOError?) -> Void) {
        let requestArgs:[String:CustomStringConvertible] = __request_args__
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
        let requestArgs:[String:CustomStringConvertible] = __request_args__
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

    /*void*/
    func __methodName__(__args__,
                        onCancelled:(() -> Void)? = nil,
                        complete:(IOError?) -> Void) {
        var canceler = Canceler()
        let requestArgs:[String:CustomStringConvertible] = __request_args__
        Network.getJsonDictFromUrl(__url__, canceler: canceler, args: requestArgs, complete: {
            (dict, error) in
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

    func fillCommentsUsers(var comments:[Comment], canceler:Canceler? = nil, onFinish:([Comment]) -> Void) {
        getUsersByIdes(try! comments.map {$0.userId}, success: {
            (users) in
            for (commentIndex, user) in zip(0..<comments.count, users) {
                comments[commentIndex].user = user
            }
            onFinish(comments)
        }, canceler: canceler)
    }
}
