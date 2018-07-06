//
//  NotificationSound.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UserNotifications

public class NotificationSound: Codable {
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
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }
}



