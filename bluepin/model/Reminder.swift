//
//  Reminder.swift
//  bluepin
//
//  Created by Alex A on 7/10/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import RealmSwift

public class Reminder: Object {
    @objc dynamic var ID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var reminderDescription: String = ""
    @objc dynamic var repeatMethod: String = ""
    @objc dynamic var repeatInterval: Int = 0
    var weekdaySet = List<Int>()
    @objc dynamic var nextReminder: Date? = nil
    var parentCategory = LinkingObjects(fromType: Category.self, property: "reminders")
    
    func repeatFormat() -> String {
        var formatString: String
        
        switch repeatMethod {
        case RepeatMethod.once.rawValue:
            formatString = "This reminder occurs once"
        case RepeatMethod.daily.rawValue:
            formatString = "This reminder repeats every \(repeatInterval) days"
        case RepeatMethod.weekly.rawValue:
            formatString = "This reminder repeats every \(repeatInterval) weeks"
        case RepeatMethod.monthly.rawValue:
            formatString = "This reminder repeats every \(repeatInterval) months"
        default:
            formatString = "This reminder occurs once"
        }
        
        if repeatInterval == 1 && repeatMethod != RepeatMethod.once.rawValue {
            formatString.removeLast()
        }
        
        return formatString
    }
    
    static func repeatFormat(withMethod method: RepeatMethod, repeatInterval: Int) -> String {
        var formatString: String
        
        switch method {
        case .once:
            formatString = "This reminder occurs once"
        case .daily:
            formatString = "This reminder repeats every \(repeatInterval) days"
        case .weekly:
            formatString = "This reminder repeats every \(repeatInterval) weeks"
        case .monthly:
            formatString = "This reminder repeats every \(repeatInterval) months"
        }
        
        if repeatInterval == 1 && method != .once {
            formatString.removeLast()
        }
        
        return formatString
    }
    
    func toIndexSet() -> IndexSet{
        
        var indexSet = IndexSet()
        
        for integer in weekdaySet {
            indexSet.insert(integer)
        }
        
        return indexSet
    }
    
    static func toRealmList(withWeekdaySet set: IndexSet) -> List<Int>{
        
        let list = List<Int>()

        set.forEach { (integer) in
            list.append(integer)
        }
        
        return list
    }
    
}

