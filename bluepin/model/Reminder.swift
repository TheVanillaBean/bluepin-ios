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
    @objc dynamic var name: String = ""
    @objc dynamic var reminderDescription: String = ""
    @objc dynamic var repeatMethod: String = ""
    @objc dynamic var repeatInterval: Int = 0
    let weekdaySet = List<Int>()
    @objc dynamic var nextReminder: Date? = nil
    var parentCategory = LinkingObjects(fromType: Category.self, property: "reminders")
}

