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
    func notification() -> BluepinNotification?
}

extension UNNotificationRequest: SystemNotification {
    
    public func notification() -> BluepinNotification? {
        let content = self.content
        
        let notification           = BluepinNotification(identifier: self.identifier, body: content.body, date: Date())
        
        let userInfo = content.userInfo

        notification.notificationInfo = notification.notification(fromDictionary: userInfo)
        
        if !content.title.trimmingCharacters(in: .whitespaces).isEmpty {
            notification.title     = content.title
        }
        
        if let trigger = self.trigger as? UNCalendarNotificationTrigger {
            
            notification.repeatTrigger = trigger
            
            notification.date      = notification.notificationInfo?.date
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

}
