//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import UIKit

public class Network {
    public static func getStringFromUrl(url:String,
                                        encoding:UInt = NSUTF8StringEncoding,
                                        runCallbackOnMainThread:Bool = true,
                                        canceler: Canceler? = nil,
                                        complete:(String?, IOError?) -> Void) {
        getDataFromUrl(url, canceler: canceler) {
            (data, error) in
            func handleResponse() {
                if let data = data {
                    if let str = String(data: data, encoding: encoding) {
                        complete(str, nil)
                    } else {
                        complete(nil, IOError.StringEncodingError)
                    }
                } else {
                    complete(nil, error)
                }
            }
            if runCallbackOnMainThread {
                Threading.runOnMainThreadIfNotCancelled(canceler, handleResponse)
            } else {
                handleResponse()
            }
        }
    }

    public static func getDataFromUrl(url:String, canceler: Canceler? = nil, complete:(NSData?, IOError?) -> Void) {
        if let url = NSURL(string: url) {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
                if let data = data {
                    complete(data, nil)
                } else {
                    complete(nil, IOError.NetworkError(error: error!))
                }
            }
            task.resume()

            if let canceler = canceler {
                canceler.body = task.cancel
            }
        } else {
            complete(nil, IOError.InvalidUrl)
        }
    }

    private static func throwErrorParseError() throws {
        throw IOError.JsonParseError(error: nil, description: "Error parse error")
    }

    public static func getJsonDictFromUrl(url:String,
                                          runCallbackOnMainThread:Bool = true,
                                          canceler: Canceler? = nil,
                                          handleResponseErrors:Bool = true,
                                          args: [String: CustomStringConvertible]? = nil,
                                          complete:([String: AnyObject]?, IOError?) -> Void) {
        let finalUrl = getUrl(url, params: args)
        print("finalUrl = \(finalUrl)")
        getDataFromUrl(finalUrl, canceler: canceler) {
            (data, error) in
            func handle() {
                if let err = error {
                    complete(nil, err)
                } else {
                    do {
                        let dict = try Json.toDictionary(data!)
                        if let err = dict["error"] where handleResponseErrors {
                            if let errString = err as? CustomStringConvertible {
                                let message = dict["message"]
                                if message != nil {
                                    if let messageString = message as? CustomStringConvertible {
                                        throw IOError.ResponseError(error: errString.description,
                                                message: messageString.description)
                                    } else {
                                        try throwErrorParseError()
                                    }
                                }

                                throw IOError.ResponseError(error: errString.description, message: nil)
                            } else {
                                try throwErrorParseError()
                            }
                            throw IOError.ResponseError(error: (err as! CustomStringConvertible).description,
                                    message: (dict["message"] as! CustomStringConvertible).description)
                        }

                        complete(dict, nil)
                    } catch let err as IOError {
                        complete(nil, err)
                    } catch {
                        assert(false)
                    }
                }
            }

            if runCallbackOnMainThread {
                Threading.runOnMainThreadIfNotCancelled(canceler, handle)
            } else {
                handle()
            }
        }
    }
    
    public static func getJsonObjectsArrayFromUrl(url:String,
                                           key:String,
                                           runCallbackOnMainThread:Bool = true,
                                           canceler: Canceler? = nil,
                                           args: [String: CustomStringConvertible]? = nil,
                                           complete:([[String:AnyObject]]?, IOError?) -> Void) {
        getJsonArrayFromUrl(url, key: key, complete: complete)
    }

    
    public static func getJsonArrayFromUrl<ObjectType>(url:String,
                                           key:String,
                                           runCallbackOnMainThread:Bool = true,
                                           canceler: Canceler? = nil,
                                           args: [String: CustomStringConvertible]? = nil,
                                           complete:([ObjectType]?, IOError?) -> Void) {
        getJsonDictFromUrl(url, canceler: canceler, runCallbackOnMainThread: runCallbackOnMainThread, args: args) {
            (dict, error) in
            if let error = error {
                complete(nil, error)
                return;
            }

            func onParseError() {
                complete(nil, IOError.JsonParseError(error: nil, description: "Item by " + key + " " +
                        "key is not an array of json objects"))
            }

            if let value = Json.getArray(dict!, key) {
                if let value = try? value.map({
                    (item:AnyObject) -> ObjectType in
                    if let item = item as? ObjectType {
                        return item
                    }

                    throw Errors.Void
                }) {
                    complete(value, nil)
                } else {
                    onParseError()
                }
            } else {
                onParseError()
            }
        }
    }
    
    public static func toQueryString(dict:[String:CustomStringConvertible]) -> String {
        let parameterArray = try! dict.map { (key, value) -> String in
            let percentEscapedKey = key.stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = value.description.stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }

        return parameterArray.joinWithSeparator("&")
    }

    public static func getUrl(base:String, params:[String:CustomStringConvertible]?) -> String {
        if let args = params {
            if !args.isEmpty {
                let concatChar = base.containsString("?") ? "&" : "?"
                let queryString = toQueryString(args)
                return base + concatChar + queryString
            }
        }

        return base
    }

    public static func getJsonLazyListWithTransformer<T, TransformType, FactoryType>(url:String,
                                          key:String,
                                          limit:Int = 10,
                                          factory: ([FactoryType]) -> [TransformType],
                                          modifyPage: (([TransformType], Canceler?, ([T]?, IOError?)->Void) -> Void),
                                          var args: [String: CustomStringConvertible] = [:],
                                          offsetKey:String = "offset",
                                          limitKey:String = "limit",
                                          mergeArgs:[String: CustomStringConvertible] = [:],
                                          onArgsMerged:(()->Void)? = nil,
                                          canceler: Canceler? = nil) -> LazyList<T, IOError> {
        args[limitKey] = limit

        var mergeApplied = mergeArgs.isEmpty
        let result = LazyList<T, IOError>()
        result.isLastPage = {
            $0.count < limit && mergeApplied
        }
        result.canceler = canceler
        result.onReload = {
            mergeApplied = false
        }

        var shouldMerge = false

        result.getNextPageData = {
            [unowned result]
            (onSuccess, onError, var pageNumber) in
            if shouldMerge {
                mergeApplied = true
                onArgsMerged?()
                args += mergeArgs
                result.pageNumber = 0
                pageNumber = 0
                args[offsetKey] = 0
                shouldMerge = false
            }
            let offset = pageNumber * limit + result.additionalOffset
            args[offsetKey] = offset
            let finalUrl = getUrl(url, params: args)
            var complete:(([FactoryType]?, IOError?) -> Void)!
            complete = {
                (array, error) in
                if let array = array {
                    shouldMerge =  array.count < limit && !mergeApplied

                    let resultArray = factory(array)
                    modifyPage(resultArray, canceler, {
                        if let page = $0 {
                            onSuccess(page)
                        } else {
                            onError($1!)
                        }
                    })
                } else {
                    onError(error!)
                }
            }
            getJsonArrayFromUrl(finalUrl, key: key, canceler: canceler, complete: complete)
        }

        return result
    }
    
    public static func getJsonLazyList<T, FactoryType>(url:String,
                                                    key:String,
                                                    limit:Int = 10,
                                                    factory: ([FactoryType]) -> [T],
                                                    modifyPage: (([T], Canceler?, ([T]?, IOError?)->Void) -> Void)? = nil,
                                                    var args: [String: CustomStringConvertible] = [:],
                                                    offsetKey:String = "offset",
                                                    limitKey:String = "limit",
                                                    mergeArgs:[String: CustomStringConvertible] = [:],
                                                    onArgsMerged:(()->Void)? = nil,
                                                    canceler: Canceler? = nil) -> LazyList<T, IOError> {
        return getJsonLazyListWithTransformer(url, key: key, factory: factory, modifyPage: {
            if let modify = modifyPage {
                modify($0, $1, $2)
            } else {
                $2($0, nil)
            }
        }, args: args, offsetKey: offsetKey, limitKey: limitKey, mergeArgs: mergeArgs, onArgsMerged: onArgsMerged, canceler: canceler)
    }

    public static func loadImageFromURL(uri:String) throws -> UIImage {
        if let url = NSURL(string: uri) {
            if let data = NSData(contentsOfURL: url) {
                throw IOError.NetworkError(error: nil)
                if let image = UIImage(data: data) {
                    return image
                }

                throw IOError.ImageDecodingError
            }
        }

        throw IOError.InvalidUrl
    }
}
