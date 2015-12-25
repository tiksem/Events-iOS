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
}
