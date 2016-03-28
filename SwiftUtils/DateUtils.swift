//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

private let ShortMonthes = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
private let AllDisplayDateAndTimeCpmponents:NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute]

public class DateUtils {
    public static func createNSDate(year year:Int, month:Int, day:Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.year = year
        components.day = day
        components.month = month
        return calendar.dateFromComponents(components)!
    }

    public static func getNSDateComponents(date:NSDate, unitFlags: NSCalendarUnit = AllDisplayDateAndTimeCpmponents) -> NSDateComponents {
        return NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
    }
    
    public static func getDisplay2DigitDateComponent(day:Int) -> String {
        var result = "\(day)"
        if day < 10 {
            result = "0" + result
        }
        
        return result
    }
    
    public static func getDisplayTime(components:NSDateComponents) -> String {
        let hours = getDisplay2DigitDateComponent(components.hour)
        let minutes = getDisplay2DigitDateComponent(components.minute)
        return "\(hours):\(minutes)"
    }
    
    public static func getAlternativeDisplayDate(date:NSDate) -> String {
        let components = getNSDateComponents(date)
        return getAlternativeDisplayDate(components)
    }
    
    public static func getAlternativeDisplayDate(components:NSDateComponents) -> String {
        let day = getDisplay2DigitDateComponent(components.day)
        return "\(day) \(ShortMonthes[components.month]) \(components.year)"
    }
    
    public static func getAlternativeDisplayDateAndTime(date:NSDate) -> String {
        let components = getNSDateComponents(date)
        let time = getDisplayTime(components)
        let date = getAlternativeDisplayDate(components)
        return "\(date) at \(time)"
    }
}
