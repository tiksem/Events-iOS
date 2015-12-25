//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public enum IOError: ErrorType, CustomStringConvertible {
    case InvalidUrl
    case NetworkError(error:NSError)
    case ResponseError
    case StringEncodingError
    case JsonParseError(error:NSError?, description:String?)

    public var description : String {
        switch self {
            case .InvalidUrl: return "InvalidUrl"
            case .NetworkError(let error):
                return "NetworkError (" + error.description + ")"
            case .ResponseError: return "ResponseError"
            case .StringEncodingError: return "StringEncodingError"
            case .JsonParseError(let error, let description):
                return "JsonParseError (" + (error?.description ?? description ?? "Unknown error") + ")"
        }
    }
}
