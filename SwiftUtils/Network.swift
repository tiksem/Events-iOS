//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class Network {
    public static func getStringFromUrl(url:String,
                                        encoding:UInt = NSUTF8StringEncoding,
                                        runCallbackOnMainThread:Bool = true,
                                        complete:(String?, IOError?) -> Void) {
        getDataFromUrl(url) {
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
                Threading.runOnMainThread(handleResponse)
            } else {
                handleResponse()
            }
        }
    }

    public static func getDataFromUrl(url:String, complete:(NSData?, IOError?) -> Void) {
        if let url = NSURL(string: url) {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
                if let data = data {
                    complete(data, nil)
                } else {
                    complete(nil, IOError.NetworkError(error: error!))
                }
            }
            task.resume()
        } else {
            complete(nil, IOError.InvalidUrl)
        }
    }

    public static func getJsonDictFromUrl(url:String,
                                          runCallbackOnMainThread:Bool = true,
                                          complete:([String: AnyObject]?, IOError?) -> Void) {
        getDataFromUrl(url) {
            (data, error) in
            if let err = error {
                complete(nil, error)
            } else {
                func handle() {
                    do {
                        let dict = try Json.toDictionary(data!)
                        complete(dict, nil)
                    } catch let err as IOError {
                        complete(nil, err)
                    } catch {
                        assert(false)
                    }
                }

                if runCallbackOnMainThread {
                    Threading.runOnMainThread(handle)
                } else {
                    handle()
                }
            }
        }
    }

    public static func getJsonArrayFromUrl(url:String, key:String,
                                          runCallbackOnMainThread:Bool = true,
                                          complete:([[String : AnyObject]]?, IOError?) -> Void) {
        getJsonDictFromUrl(url, runCallbackOnMainThread: runCallbackOnMainThread) {
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
}
