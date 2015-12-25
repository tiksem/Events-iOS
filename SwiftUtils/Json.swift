//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class Json {
    public func toObject(data:NSData) throws -> AnyObject {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch let error as NSError{
            throw IOError.JsonParseError(error: error, description: nil)
        }
    }

    public func toDictionary(data:NSData) throws -> Dictionary<String, AnyObject> {
        if let result = try toObject(data) as? [String:AnyObject] {
            return result;
        } else {
            throw IOError.JsonParseError(error: nil, description: "Not a dictionary");
        }
    }
}
