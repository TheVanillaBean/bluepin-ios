//
//  Date+Scheduler.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import SwiftDate

public extension Date {
    
    func relativeFormat() -> String {
        
        if self.compare(.isToday) {
            return self.inDefaultRegion().toFormat("'Today,' EEEE MMMM d 'at' h:mm a", locale: Locales.english)
        } else if self.compare(.isTomorrow){
            return self.inDefaultRegion().toFormat("'Tomorrow,' EEEE MMMM d 'at' h:mm a", locale: Locales.english)
        } else {
            return self.inDefaultRegion().toFormat("EEEE, MMMM d 'at' h:mm a", locale: Locales.english)
        }
    
    }
    
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}

// MARK: Helper methods
public extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}

public extension Date {
    
    
    
    /// Adds a number of minutes to a date.
    /// > This method can add and subtract minutes.
    ///
    /// - Parameter minutes: The number of minutes to add/subtract.
    /// - Returns: The date after the minutes addition/subtraction.
    func next(minutes: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.minute = minutes
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /// Adds a number of hours to a date.
    /// > This method can add and subtract hours.
    ///
    /// - Parameter hours: The number of hours to add/subtract.
    /// - Returns: The date after the hours addition/subtraction.
    func next(hours: Int) -> Date {
        return self.next(minutes: hours * 60)
    }
    
    /// Adds a number of days to a date.
    /// >This method can add and subtract days.
    ///
    /// - Parameter days: The number of days to add/subtract.
    /// - Returns: The date after the days addition/subtraction.
    func next(days: Int) -> Date {
        return self.next(minutes: days * 60 * 24)
    }
    
    /// Removes the seconds component from the date.
    ///
    /// - Returns: The date after removing the seconds component.
    func removeSeconds() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)!
    }
    
    /// Creates a date object with the given time and offset. The offset is used to align the time with the GMT.
    ///
    /// - Parameters:
    ///   - time: The required time of the form HHMM.
    ///   - offset: The offset in minutes.
    /// - Returns: Date with the specified time and offset.
    static func date(withTime time: Int, offset: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: Date())
        components.minute = (time % 100) + offset % 60
        components.hour = (time / 100) + (offset / 60)
        var date = calendar.date(from: components)!
        if date < Date() {
            date = date.next(days: 1)
        }
        
        return date
    }
}


