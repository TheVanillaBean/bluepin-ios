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

public enum RepeatMethod: String, Codable {
    case once  = "Once"
    case daily  = "Daily"
    case weekly   = "Weekly"
    case monthly  = "Monthly"
}

public class BluepinNotification: NSObject, Codable {
    
    fileprivate(set) public var identifier: String!
    
    public var body: String!
    
    public var date: Date! {
        didSet {
            self.notificationInfo.date = self.date
        }
    }
    
    public var notificationInfo: BPNotificationInfo = BPNotificationInfo()
    
    public var title: String?                  = nil
    
    public var badge: NSNumber?                = 0
    
    public var sound: NotificationSound = NotificationSound()
    
    internal(set) public var scheduled: Bool   = false
    
    public var repeatMethod: RepeatMethod = .once
    
    public var repeatInterval: Int = 0
    
    public var repeatTrigger: UNCalendarNotificationTrigger?
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case body
        case date
        case notificationInfo
        case title
        case badge
        case sound
        case scheduled
        case repeatMethod
        case repeatInterval
        case repeatTrigger
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(body, forKey: .body)
        try container.encode(date, forKey: .date)
        try container.encode(notificationInfo, forKey: .notificationInfo)
        try container.encode(title, forKey: .title)
        try container.encode(badge?.intValue, forKey: .badge)
        try container.encode(sound, forKey: .sound)
        try container.encode(scheduled, forKey: .scheduled)
        try container.encode(repeatMethod, forKey: .repeatMethod)
        try container.encode(repeatInterval, forKey: .repeatInterval)
        try container.encode(repeatTrigger?.nextTriggerDate(), forKey: .repeatTrigger)
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        body = try values.decode(String.self, forKey: .body)
        date = try values.decode(Date.self, forKey: .date)
        notificationInfo = try values.decode(BPNotificationInfo.self, forKey: .notificationInfo)
        title = try values.decode(String.self, forKey: .title)
        badge = try NSNumber(value: values.decode(Int.self, forKey: .badge))
        sound = try values.decode(NotificationSound.self, forKey: .sound)
        scheduled = try values.decode(Bool.self, forKey: .scheduled)
        repeatMethod = try values.decode(RepeatMethod.self, forKey: .repeatMethod)
        repeatInterval = try values.decode(Int.self, forKey: .repeatInterval)
        repeatTrigger = try trigger(forTrigger: nil, date: values.decode(Date.self, forKey: .repeatTrigger))
    }
    
    public override var description: String {
        var result  = ""
        result += "Notification: \(self.identifier!)\n"
        if let title = self.title {
            result += "\tTitle: \(title)\n"
        }
        result += "\tBody: \(self.body!)\n"
        result += "\tFires at: \(self.date!)\n"
        result += "\tUser info: \(self.notificationInfo)\n"
        if let badge = self.badge {
            result += "\tBadge: \(badge)\n"
        }
        result += "\tSound name: \(self.sound)\n"
        result += "\tScheduled: \(self.scheduled)"
        
        return result
    }
    
    public init(identifier: String = UUID().uuidString, title: String, body: String, date: Date) {
        super.init()
        self.identifier = identifier
        self.body = body
        self.title = title
        self.date = date
        self.notificationInfo.identifier = identifier
        self.notificationInfo.date = self.date
        self.repeatTrigger = trigger(forTrigger: nil, date: date)
    }
    
    public convenience init(identifier: String = UUID().uuidString, title: String, body: String, date: Date, repeatMethod: RepeatMethod, repeatInterval: Int, repeatTrigger: UNCalendarNotificationTrigger?, weekdaySet: IndexSet = IndexSet([1, 2])) {
        self.init(identifier: identifier, title: title, body: body, date: date)
        self.repeatMethod = repeatMethod
        self.repeatInterval = repeatInterval
        self.repeatTrigger = repeatTrigger != nil ? trigger(forTrigger: repeatTrigger, date: date) : self.repeatTrigger
        self.notificationInfo.repeatMethod = self.repeatMethod
        self.notificationInfo.repeatInterval = self.repeatInterval
        if self.repeatMethod == .weekly {
            self.notificationInfo.repeatWeekdayInterval = weekdaySet
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
    
    public func notificationDictionary() -> [AnyHashable : Any]{
        
        let weekday = self.notificationInfo.repeatWeekdayInterval != nil ? Array(self.notificationInfo.repeatWeekdayInterval!) : Array()
        
        let userInfo: [AnyHashable : Any] = [
            IdentifierKey : self.notificationInfo.identifier,
            DateKey : self.notificationInfo.date,
            RepeatMethodKey : self.notificationInfo.repeatMethod.rawValue,
            RepeatIntervalKey : self.notificationInfo.repeatInterval,
            RepeatWeekdayKey : weekday
        ]
        return userInfo
    }
    
    public func notification(fromDictionary dictionary: [AnyHashable : Any]) -> BPNotificationInfo {
        let notification: BPNotificationInfo = BPNotificationInfo()
        notification.identifier = dictionary[IdentifierKey] as! String
        notification.date = dictionary[DateKey] as! Date
        notification.repeatMethod = RepeatMethod(rawValue: dictionary[RepeatMethodKey] as! String)!
        notification.repeatInterval = dictionary[RepeatIntervalKey] as! Int
        notification.repeatWeekdayInterval = IndexSet(dictionary[RepeatWeekdayKey] as! Array)
        return notification
    }
    
}

public func ==(lhs: BluepinNotification, rhs: BluepinNotification) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func <(lhs: BluepinNotification, rhs: BluepinNotification) -> Bool {
    return lhs.date.compare(rhs.date) == ComparisonResult.orderedAscending
}


