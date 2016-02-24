//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public enum IOError: ErrorType, CustomStringConvertible {
    case InvalidUrl
    case NetworkError(error:NSError?)
    case ImageDecodingError
    case ResponseError(error:String, message:String?)
    case StringEncodingError
    case JsonParseError(error:NSError?, description:String?)

    public var description : String {
        switch self {
            case .InvalidUrl: return "InvalidUrl"
            case .NetworkError(let error):
                return "NetworkError (" + (error?.description ?? "Unknown Error") + ")"
            case .ResponseError(let error, let message):
                if let message = message {
                    return "ResponseError(\(error): \(message))"
                } else {
                    return "ResponseError(\(error))"
                }
            case .StringEncodingError: return "StringEncodingError"
            case .ImageDecodingError: return "ImageDecodingError"
            case .JsonParseError(let error, let description):
                return "JsonParseError (" + (error?.description ?? description ?? "Unknown error") + ")"
        }
    }
}
