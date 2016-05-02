//
// Created by Semyon Tikhonenko on 12/25/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class Json {
    public static func toObject(data:NSData) throws -> AnyObject {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch let error as NSError{
            throw IOError.JsonParseError(error: error, description: nil)
        }
    }

    public static func toDictionary(data:NSData) throws -> Dictionary<String, AnyObject> {
        if let result = try toObject(data) as? [String:AnyObject] {
            return result;
        } else {
            throw IOError.JsonParseError(error: nil, description: "Not a dictionary");
        }
    }

    public static func getInt(jsonDict:Dictionary<String, AnyObject>, _ key:String) -> Int? {
        if let value = jsonDict[key] {
            if let str = value as? String {
                return Int(str)
            } else if let number = value as? NSNumber {
                return number.integerValue
            }
        }

        return nil
    }

    public static func getString(jsonDict:Dictionary<String, AnyObject>, _ key:String) -> String? {
        if let value = jsonDict[key] as? CustomStringConvertible {
            return value.description
        }

        return nil
    }

    public static func getBool(jsonDict:Dictionary<String, AnyObject>, _ key:String) -> Bool {
        if let value = jsonDict[key] {
            if let str = value as? String {
                return str == "true"
            } else if let number = value as? NSNumber {
                return number.integerValue == 1
            }
        }

        return false
    }

    public static func getArray(jsonDict:Dictionary<String, AnyObject>, _ key:String) -> [AnyObject]? {
        return jsonDict[key] as? Array<AnyObject>
    }
    
    public static func getDictionary(jsonDict:Dictionary<String, AnyObject>, _ key:String) -> Dictionary<String, AnyObject>? {
        return jsonDict[key] as? Dictionary<String, AnyObject>
    }
}
