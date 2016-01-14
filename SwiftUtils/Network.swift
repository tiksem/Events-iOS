//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

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

    public static func getJsonDictFromUrl(url:String,
                                          runCallbackOnMainThread:Bool = true,
                                          canceler: Canceler? = nil,
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

    public static func getJsonArrayFromUrl(url:String,
                                           key:String,
                                           runCallbackOnMainThread:Bool = true,
                                           canceler: Canceler? = nil,
                                           args: [String: CustomStringConvertible]? = nil,
                                           complete:([[String : AnyObject]]?, IOError?) -> Void) {
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
                    (item:AnyObject) -> [String:AnyObject] in
                    if let item = item as? [String:AnyObject] {
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
                var queryString = toQueryString(args)
                return base + concatChar + queryString
            }
        }

        return base
    }

    public static func getJsonLazyList<T>(url:String,
                                          key:String,
                                          limit:Int = 10,
                                          factory: ([[String:AnyObject]]) -> [T],
                                          var args: [String: CustomStringConvertible] = [:],
                                          offsetKey:String = "offset",
                                          limitKey:String = "limit",
                                          canceler: Canceler? = nil) -> LazyList<T, IOError> {
        args[limitKey] = limit

        let result = LazyList<T, IOError>(getNextPageData: {
            (onSuccess, onError, pageNumber) in
            let offset = pageNumber * limit
            args[offsetKey] = offset
            let finalUrl = getUrl(url, params: args)
            getJsonArrayFromUrl(finalUrl, key: key, canceler: canceler, complete: {
                (array, error) in
                if let array = array {
                    onSuccess(factory(array))
                } else {
                    onError(error!)
                }
            })
        })

        return result
    }
}
