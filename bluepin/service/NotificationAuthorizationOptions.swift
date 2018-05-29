//
//  NotificationAuthorizationOptions.swift
//  bluepin
//
//  Created by Alex on 5/21/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

public struct NotificationAuthorizationOptions: OptionSet, RawRepresentable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let badge = NotificationAuthorizationOptions(rawValue: 1 << 0)
    public static let sound = NotificationAuthorizationOptions(rawValue: 1 << 1)
    public static let alert = NotificationAuthorizationOptions(rawValue: 1 << 2)
}
