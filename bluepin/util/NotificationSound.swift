//
//  NotificationSound.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UserNotifications

public class NotificationSound {
    internal var name: String?
    internal var sound: UNNotificationSound?

    public init(named name: String = BluepinNotification.defaultSoundName) {
        self.name = name
    }

    internal init(sound: UNNotificationSound) {
        self.sound = sound
    }
    
    public func isValid() -> Bool {
        return self.name != nil
    }
}


