//
// Created by Semyon Tikhonenko on 3/24/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

private let ShortMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
private let AllDisplayDateAndTimeComponents:NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute]

public class DateUtils {
    public static func createNSDate(year year:Int, month:Int, day:Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.year = year
        components.day = day
        components.month = month
        return calendar.dateFromComponents(components)!
    }

    public static func getNSDateComponents(date:NSDate, unitFlags: NSCalendarUnit = AllDisplayDateAndTimeComponents) -> NSDateComponents {
        return NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
    }
    
    public static func getNowNSDateComponents(unitFlags: NSCalendarUnit = AllDisplayDateAndTimeComponents) -> NSDateComponents {
        let now = NSDate()
        return getNSDateComponents(now)
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
        return "\(day) \(ShortMonths[components.month - 1]) \(components.year)"
    }
    
    public static func getAlternativeDisplayDateWithoutYear(components:NSDateComponents) -> String {
        let day = getDisplay2DigitDateComponent(components.day)
        return "\(day) \(ShortMonths[components.month - 1])"
    }
    
    public static func getAlternativeDisplayDateAndTime(date:NSDate, considerCurrentYear:Bool = true) -> String {
        let components = getNSDateComponents(date)
        let time = getDisplayTime(components)
        let date = considerCurrentYear ?
            getAlternativeDisplayDateDependingOnCurrentYear(components, nowComp: getNowNSDateComponents()) :
            getAlternativeDisplayDate(components)
        return "\(date) at \(time)"
    }
    
    public static func getAlternativeDisplayDateDependingOnCurrentYear(dateComp:NSDateComponents, nowComp:NSDateComponents) -> String {
        if (nowComp.year == dateComp.year) {
            return getAlternativeDisplayDateWithoutYear(dateComp)
        } else {
            return getAlternativeDisplayDate(dateComp)
        }
    }
    
    public static func getOneHourAgoDisplayDateFormat(date:NSDate) -> String {
        var ignore:Bool = false
        return getOneHourAgoDisplayDateFormat(date, isAgo: &ignore)
    }
    
    public static func getOneHourAgoDisplayDateFormat(date:NSDate, inout isAgo:Bool) -> String {
        let dateComp = getNSDateComponents(date)
        let now = NSDate()
        let nowComp = getNSDateComponents(now)
        let diff = now.timeIntervalSince1970 - date.timeIntervalSince1970
        if (diff < 60) {
            isAgo = true
            return "Just now"
        }
        
        if (diff < 3600) {
            isAgo = true
            let minutes = Int(round(diff / 60))
            let minutesText = minutes == 1 ? "minute" : "minutes"
            return "\(minutes) \(minutesText) ago"
        }
        
        isAgo = false
        
        if (diff < 2 * 24 * 3600) {
            if (nowComp.day == dateComp.day) {
                return "Today at " + getDisplayTime(dateComp)
            } else if(nowComp.day - dateComp.day == -1) {
                return "Yesterday at " + getDisplayTime(dateComp)
            }
        }
        
        return getAlternativeDisplayDateDependingOnCurrentYear(dateComp, nowComp: nowComp) + " at " + getDisplayTime(dateComp)
    }
}
