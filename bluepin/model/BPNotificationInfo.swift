//
//  BPNotificationInfo.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation

public class BPNotificationInfo: Codable {
    
    public var identifier: String = ""
    public var date: Date = Date()
    public var repeatMethod: RepeatMethod = .once
    public var repeatInterval: Int = 0
    public var repeatWeekdayInterval: IndexSet?
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case date
        case repeatMethod
        case repeatInterval
        case repeatWeekdayInterval
    }
    
    init() {}
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(date, forKey: .date)
        try container.encode(repeatMethod, forKey: .repeatMethod)
        try container.encode(repeatInterval, forKey: .repeatInterval)
        try container.encodeIfPresent(repeatWeekdayInterval, forKey: .repeatWeekdayInterval)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        date = try values.decode(Date.self, forKey: .date)
        repeatMethod = try values.decode(RepeatMethod.self, forKey: .repeatMethod)
        repeatInterval = try values.decode(Int.self, forKey: .repeatInterval)
        repeatWeekdayInterval = try values.decodeIfPresent(IndexSet.self, forKey: .repeatWeekdayInterval)
    }
    
}
