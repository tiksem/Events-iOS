//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public class DateUtils {
    public static func createNSDate(year year:Int, month:Int, day:Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.year = year
        components.day = day
        components.month = month
        return calendar.dateFromComponents(components)!
    }

    public static func getAlternativeDisplayDate(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(date)
    }
}
