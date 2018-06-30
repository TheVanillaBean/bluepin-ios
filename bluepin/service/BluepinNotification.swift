//
//  Notification.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import SwiftDate
import UserNotifications

public enum Repeats: String, Codable {
    case none  = "None"
    case hour  = "Hour"
    case day   = "Day"
    case week  = "Week"
    case month = "Month"
}

public enum RepeatMethod: String, Codable {
    case once  = "Once"
    case daily  = "Daily"
    case weekly   = "Weekly"
    case monthly  = "Monthly"
}

public class BluepinNotification: NSObject, Codable {
    
    public static let identifierKey: String    = "NotificationIdentifierKey"
    
    public static let dateKey: String          = "NotificationDateKey"
    
    public static let defaultSoundName: String = "NotificationDefaultSound"
    
    public static let repeatMethodKey: String = "NotificationRepeatMethod"
    
    public static let repeatIntervalKey: String = "NotificationRepeatInterval"
    
    public static let repeatWeekdayKey: String = "NotificationRepeatWeekdaySet"
    
    
    fileprivate(set) public var identifier: String!
    
    public var body: String!
    
    public var date: Date! {
        didSet {
            self.userInfo[BluepinNotification.dateKey] = self.date
        }
    }
    
    private(set) public var userInfo: [AnyHashable : Any]!
    
    public var title: String?                  = nil
    
    public var badge: NSNumber?                = nil
    
    public var sound: NotificationSound = NotificationSound()
    
    public var repeats: Repeats                = .none
        
    internal(set) public var scheduled: Bool   = false
    
    public var repeatMethod: RepeatMethod = .once
    
    public var repeatInterval: Int = 0
    
    public var repeatTrigger: UNCalendarNotificationTrigger?
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case body
//        case date
//        case userInfo
//        case title
//        case badge
//        case sound
//        case repeats
//        case scheduled
//        case repeatMethod
//        case repeatInterval
//        case repeatTrigger
    }
    
    public required init(from decoder: Decoder) throws {
        print("Called")
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        body = try values.decode(String.self, forKey: .body)
    }
    
    
    
    public override var description: String {
        var result  = ""
        result += "Notification: \(self.identifier!)\n"
        if let title = self.title {
            result += "\tTitle: \(title)\n"
        }
        result += "\tBody: \(self.body!)\n"
        result += "\tFires at: \(self.date!)\n"
        result += "\tUser info: \(self.userInfo!)\n"
        if let badge = self.badge {
            result += "\tBadge: \(badge)\n"
        }
        result += "\tSound name: \(self.sound)\n"
        result += "\tRepeats every: \(self.repeats.rawValue)\n"
        result += "\tScheduled: \(self.scheduled)"
        
        return result
    }
    
    public init(identifier: String = UUID().uuidString, body: String, date: Date = Date().next(hours: 1)) {
        super.init()
        self.identifier = identifier
        self.body = body
        self.date = date
        self.userInfo = [
            BluepinNotification.identifierKey : self.identifier,
            BluepinNotification.dateKey : self.date
        ]
        self.repeatTrigger = trigger(forTrigger: nil, date: date)
    }
    
    public convenience init(identifier: String = UUID().uuidString, body: String, date: Date = Date().next(hours: 1), repeatMethod: RepeatMethod, repeatInterval: Int, repeatTrigger: UNCalendarNotificationTrigger?, weekdaySet: IndexSet = IndexSet([1, 2])) {
        self.init(identifier: identifier, body: body, date: date)
        self.repeatMethod = repeatMethod
        self.repeatInterval = repeatInterval
        self.repeatTrigger = trigger(forTrigger: repeatTrigger, date: date)
        self.userInfo[BluepinNotification.repeatMethodKey] = self.repeatMethod
        self.userInfo[BluepinNotification.repeatIntervalKey] = self.repeatInterval
        if self.repeatMethod == .weekly {
            self.userInfo[BluepinNotification.repeatWeekdayKey] = weekdaySet
        }
    }
    
    func trigger(forTrigger trigger: UNCalendarNotificationTrigger?, date: Date) -> UNCalendarNotificationTrigger{
        if let notificationTrigger = trigger {
            return notificationTrigger
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
    }
    
    public static func notification(withRequest sytemNotification: SystemNotification) -> BluepinNotification? {
        return sytemNotification.notification()
    }
    
    public func setUserInfo(value: Any, forKey key: AnyHashable) {
        if let keyString = key as? String {
            if (keyString == BluepinNotification.identifierKey || keyString == BluepinNotification.dateKey) {
                return
            }
        }
        self.userInfo[key] = value;
    }

    public func removeUserInfoValue(forKey key: AnyHashable) {
        if let keyString = key as? String {
            if (keyString == BluepinNotification.identifierKey || keyString == BluepinNotification.dateKey) {
                return
            }
        }
        self.userInfo.removeValue(forKey: key)
    }
}

public func ==(lhs: BluepinNotification, rhs: BluepinNotification) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func <(lhs: BluepinNotification, rhs: BluepinNotification) -> Bool {
    return lhs.date.compare(rhs.date) == ComparisonResult.orderedAscending
}

extension BluepinNotification{
    public func encode(to encoder: Encoder) throws {
        print("Called")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(body, forKey: .body)
//        try container.encode(date, forKey: .date)
//        try container.encode(userInfo, forKey: .userInfo)
//        try container.encode(title, forKey: .title)
//        try container.encode(badge, forKey: .badge)
//        try container.encode(sound, forKey: .sound)
//        try container.encode(repeats, forKey: .repeats)
//        try container.encode(scheduled, forKey: .scheduled)
//        try container.encode(repeatMethod, forKey: .repeatMethod)
//        try container.encode(repeatInterval, forKey: .repeatInterval)
//        try container.encode(repeatTrigger, forKey: .repeatTrigger)
    }
}


