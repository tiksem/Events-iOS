//
// Created by Semyon Tikhonenko on 12/26/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public struct Arrays {
    private enum Fail : ErrorType {
        case TypeCast
    }

    public static func mapTypes<To : AnyObject>(_ array:[AnyObject], _:To.Type) -> [To]? {
        do {
            return try array.map {
                (item:AnyObject) -> To in
                if let result = item as? To {
                   return result
                } else {
                    throw Fail.TypeCast
                }
            }
        } catch {
            return nil
        }
    }
}
