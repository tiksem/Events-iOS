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
                               complete:([String: AnyObject]?, IOError?) -> Void,
                               onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonDictFromUrl(url, complete: complete, canceler: canceler)
        cancelers.add(canceler, onCancelled: onCancelled)
    }

    private func getJsonArray(url:String,
                              key:String,
                              args: [String: CustomStringConvertible]? = nil,
                              complete:([[String: AnyObject]]?, IOError?) -> Void,
                              onCancelled:(() -> Void)? = nil) {
        var canceler = Canceler()
        Network.getJsonArrayFromUrl(url, key: key, canceler: canceler, complete: complete)
        cancelers.add(canceler, onCancelled: onCancelled)
    }

    private func getLazyList<T>(url:String,
                                key:String,
                                limit:Int = 10,
                                factory: ([[String:AnyObject]]) -> [T],
                                var args: [String: CustomStringConvertible] = [:],
                                offsetKey:String = "offset",
                                limitKey:String = "limit") -> LazyList<T, IOError> {
        var canceler = Canceler()
        cancelers.add(canceler)
        return Network.getJsonLazyList(url, key: key,
                limit: limit, factory: factory, args: args,
                offsetKey: offsetKey, limitKey: limitKey)
    }/*helpers*/
    /*lazyList*/
    func __methodName__() -> LazyList<__ParamName__, IOError> {
        return getLazyList(__url__, key: __key__, limit: __limit__, factory: {
            return __ParamName__.to__ParamName__sArray($0)
        })
    }
    /*}*/

    /*array*/
    func __methodName__(__args__,
                        complete:([__ParamName__]?, IOError?) -> Void,
                        onCancelled:(() -> Void)? = nil) {
        let args = __request_args__
        getJsonArray(__url__, key: __key__, args: args, complete: {
            complete(__ParamName__.to__ParamName__sArray($0), $1)
        }, onCancelled: onCancelled);
    }
    /*}*/

    /*helpersEnd*/
    /*BODY*/
}
