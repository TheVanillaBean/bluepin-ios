//
//  Notification.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation

public enum Repeats: String {
    case none  = "None"
    case hour  = "Hour"
    case day   = "Day"
    case week  = "Week"
    case month = "Month"
}

public class BluepinNotification: NSObject {
    
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
    
    public static let identifierKey: String    = "NotificationIdentifierKey"
    
    public static let dateKey: String          = "NotificationDateKey"
    
    public static let defaultSoundName: String = "NotificationDefaultSound"
    
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
        self.identifier = identifier
        self.body = body
        self.date = date
        self.userInfo = [
            BluepinNotification.identifierKey : self.identifier,
            BluepinNotification.dateKey : self.date
        ]
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

