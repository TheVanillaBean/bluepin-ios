//
//  Category.swift
//  bluepin
//
//  Created by Alex A on 7/10/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let reminders = List<Reminder>()
}
