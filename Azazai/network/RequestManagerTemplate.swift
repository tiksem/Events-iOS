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
    }/*helpers*/
    /*lazyList*/
    func __methodName__(__args__) -> LazyList<__ParamName__, IOError> {
        let requestArgs:[String:CustomStringConvertible] = __request_args__
        let mergeArgs:[String:CustomStringConvertible] = __merge_args__
        return getLazyList(__url__, key: __key__, limit: __limit__, factory: {
            return __ParamName__.to__ParamName__sArray($0)!
        }, args: requestArgs, mergeArgs: mergeArgs)
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
            } else if let id = $0![key] as? __ParamName__ {
                complete(id, nil)
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
}
