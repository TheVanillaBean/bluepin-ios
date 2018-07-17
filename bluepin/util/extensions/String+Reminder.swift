//
//  String+Reminder.swift
//  bluepin
//
//  Created by Alex A on 7/15/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import SwiftDate

public extension String {
    
    func repeatFormat(reminder: Reminder) -> String {
        
        print(("interval \(reminder.repeatInterval)"))
        
        var formatString: String
        
        switch reminder.repeatMethod {
        case RepeatMethod.once.rawValue:
            formatString = "This reminder repeats once"
        case RepeatMethod.daily.rawValue:
            formatString = "This reminder repeats every \(reminder.repeatInterval) days"
        case RepeatMethod.weekly.rawValue:
            formatString = "This reminder repeats every \(reminder.repeatInterval) weeks"
        case RepeatMethod.monthly.rawValue:
            formatString = "This reminder repeats every \(reminder.repeatInterval) months"
        default:
            formatString = "This reminder repeats once"
        }
        
        if reminder.repeatInterval == 1 {
            formatString.removeLast()
            print(formatString)
        }
        
        return formatString
        
    }
}
