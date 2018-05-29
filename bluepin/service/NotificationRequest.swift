//
//  NotificationRequest.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import UserNotifications

public protocol SystemNotification {
    
    /// Creates a `RobinNotification` from the passed `SystemNotification`. For the details of the creation process, have a look at the system notifications extensions that implement the `SystemNotification` protocol.
    ///
    /// - Parameter notification: The system notification to create the `RobinNotification` from.
    /// - Returns: The `RobinNotification` if the creation succeeded, nil otherwise.
    func notification() -> BluepinNotification?
    
}

extension UNNotificationRequest: SystemNotification {
    
    public func notification() -> BluepinNotification? {
        let content = self.content
        
        let notification           = BluepinNotification(identifier: self.identifier, body: content.body, date: Date())
        
        let userInfo = content.userInfo
        for (key, value) in userInfo {
            notification.setUserInfo(value: value, forKey: key)
        }
        
        if !content.title.trimmingCharacters(in: .whitespaces).isEmpty {
            notification.title     = content.title
        }
        
        if let trigger = self.trigger as? UNCalendarNotificationTrigger {
            var date: Date?
            if let originalDate    = notification.userInfo[BluepinNotification.dateKey] as? Date {
                date               = originalDate
            }
            print("Repeats is Set: \(trigger))")
            notification.repeats   = self.repeats(dateComponents: trigger.dateComponents)
            notification.date      = self.date(fromDateComponents: trigger.dateComponents, repeats: notification.repeats, originalDate: date)
        }
        
        notification.badge         = content.badge
        
        if let sound = content.sound {
            if sound != UNNotificationSound.default() {
                notification.sound = NotificationSound(sound: sound)
            }
        }
        
        notification.scheduled     = true
        
        return notification
    }
    
    /// Since repeating a `UNCalendarNotificationTrigger` nullifies some of the
    /// date components, the original date needs to be stored. Robin stores this date
    /// in the notification's `userInfo` property using `RobinNotification.dateKey`.
    /// This original date is used to fill those nullified components.
    ///
    /// - Parameters:
    ///   - dateComponents: The `UNCalendarNotificationTrigger` date components.
    ///   - repeats: The repeat interval of the trigger.
    ///   - originalDate: The original date stored to fill the nullified components. Uses current date if passed as `nil`.
    /// - Returns: The filled date using the original date.
    private func date(fromDateComponents dateComponents: DateComponents, repeats: Repeats, originalDate: Date?) -> Date {
        let calendar: Calendar         = Calendar.current
        var components: DateComponents = dateComponents
        
        var date: Date
        if originalDate == nil {
            date = Date()
        } else {
            date = originalDate!
        }
        
        switch repeats {
        case .none:
            return calendar.date(from: components)!
        case .month:
            let comps        = calendar.dateComponents([.year, .month], from: date)
            components.year  = comps.year
            components.month = comps.month
            
            return calendar.date(from: components)!
        case .week:
            let comps        = calendar.dateComponents([.year, .month, .day], from: date)
            components.year  = comps.year
            components.month = comps.month
            components.day   = comps.day
            
            return calendar.date(from: components)!
        case .day:
            let comps        = calendar.dateComponents([.year, .month, .day], from: date)
            components.year  = comps.year
            components.month = comps.month
            components.day   = comps.day
            
            return calendar.date(from: components)!
        case .hour:
            let comps        = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            components.year  = comps.year
            components.month = comps.month
            components.day   = comps.day
            components.hour  = comps.hour
            
            return calendar.date(from: components)!
        case .second:
            let comps        = calendar.dateComponents([.year, .month, .day, .hour, .second], from: date)
            components.year  = comps.year
            components.month = comps.month
            components.day   = comps.day
            components.hour  = comps.hour
            components.second = comps.second
            
            return calendar.date(from: components)!
        }
        
    }
    
    private func repeats(dateComponents components: DateComponents) -> Repeats {
        if self.doesRepeatNone(dateComponents: components) {
            return .none
        } else if doesRepeatMonth(dateComponents: components) {
            return .month
        } else if doesRepeatWeek(dateComponents: components) {
            return .week
        } else if doesRepeatDay(dateComponents: components) {
            return .day
        } else if doesRepeatHour(dateComponents: components) {
            return .hour
        }
        
        return .none
    }
    
    private func doesRepeatNone(dateComponents components: DateComponents) -> Bool {
        return components.year != nil && components.month != nil && components.day != nil && components.hour != nil && components.minute != nil
    }
    
    private func doesRepeatMonth(dateComponents components: DateComponents) -> Bool {
        return components.day != nil && components.hour != nil && components.minute != nil
    }
    
    private func doesRepeatWeek(dateComponents components: DateComponents) -> Bool {
        return components.weekday != nil && components.hour != nil && components.minute != nil && components.second != nil
    }
    
    private func doesRepeatDay(dateComponents components: DateComponents) -> Bool {
        return components.hour != nil && components.minute != nil && components.second != nil
    }
    
    private func doesRepeatHour(dateComponents components: DateComponents) -> Bool {
        return components.minute != nil && components.second != nil
    }
}
