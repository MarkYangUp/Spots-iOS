//
//  Structure.swift
//  Spots
//
//  Created by Mark Jackson on 4/1/16.
//  Copyright © 2016 Mark Jackson. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

struct SpotsResponse: Mappable {
    
    var structures : [Structure]!
    var lastUpdatedDate : NSDate {
        return NSDate()
    }
    
    init?(_ map: Map) { }
    
    mutating func mapping(map: Map) {
        structures <- map["Structures"]
    }
}

struct Structure: Mappable {
    
    private var _levels : [Level]!
    var levels : [Level]! {
        get {
            if self._levels == nil { return nil }
            let l = self._levels[1..<self._levels.count]
            return Array(l)
        }
    }
    var available : Int!
    var name : String!
    var total : Int!
    var lastUpdated : String!
    var lastUpdatedDate : NSDate {
        let match = matchesForRegexInText("([0-9]+)", text: lastUpdated)
        if let firstMatch = match.first,
            let date = Double(firstMatch) {
            return NSDate(timeIntervalSince1970: date)
        }
        return NSDate()
    }
    
    init?(_ map: Map) { }
    
    init() { }
    
    mutating func mapping(map: Map) {
        _levels <- map["Levels"]
        available <- map["CurrentCount"]
        name <- map["Name"]
        total <- map["Capacity"]
        lastUpdated <- map["Timestamp"]
    }
}

struct Level : Mappable {
    
    var available : Int!
    var name : String!
    var total : Int!
    
    init?(_ map: Map) { }
    
    mutating func mapping(map: Map) {
        available <- map["CurrentCount"]
        name <- map["FriendlyName"]
        total <- map["Capacity"]
    }
    
}

/**
 Takes a past NSDate and creates a string representation of it.
 
 ex: "1 week ago"
 
 ex: "Last week"
 
 - Parameter date: Past date you wish to create a string representation for.
 - Parameter numericDates: if true, ex: "1 week ago", else ex: "Last week"
 - Returns: String that represents your date.
 */
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
public func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = (earliest == now) ? date : now
    // swiftlint:disable line_length
    let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
    
    if components.year >= 2 {
        return "\(components.year) years ago"
    } else if components.year >= 1 {
        if numericDates {
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if components.month >= 2 {
        return "\(components.month) months ago"
    } else if components.month >= 1 {
        if numericDates {
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if components.weekOfYear >= 2 {
        return "\(components.weekOfYear) weeks ago"
    } else if components.weekOfYear >= 1 {
        if numericDates {
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if components.day >= 2 {
        return "\(components.day) days ago"
    } else if components.day >= 1 {
        if numericDates {
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if components.hour >= 2 {
        return "\(components.hour) hours ago"
    } else if components.hour >= 1 {
        if numericDates {
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if components.minute >= 2 {
        return "\(components.minute) minutes ago"
    } else if components.minute >= 1 {
        if numericDates {
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if components.second >= 3 {
        return "\(components.second) seconds ago"
    } else {
        return "just now"
    }
    
}

extension NSDate {
    func formattedString(dateFormat : String, timezone : String) -> String {
        let dateFormatter = getDateFormatter(dateFormat, timezone: timezone)
        return dateFormatter.stringFromDate(self)
    }
    
    func timeAgoString() -> String {
        return timeAgoSinceDate(self, numericDates: true)
    }
}

extension String {
    func dateWithFormat(dateFormat : String, timezone : String) -> NSDate {
        let dateFormatter = getDateFormatter(dateFormat, timezone: timezone)
        return dateFormatter.dateFromString(self)!
    }
}

public func getDateFormatter(dateFormat : String, timezone : String) -> NSDateFormatter {
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone(abbreviation: timezone)
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch {
        return []
    }
}
