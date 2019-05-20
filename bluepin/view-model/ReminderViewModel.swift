//
//  ReminderViewModel.swift
//  bluepin
//
//  Created by Alex A on 5/18/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import Foundation
import RealmSwift

class ReminderViewModel {
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)
    
    fileprivate var _reminderNotif: [BluepinNotification]?
    fileprivate var _realmReminder: Reminder?
    fileprivate var _selectedCategory: Category?
    fileprivate var _userCategories: Results<Category>?
    fileprivate var _userReminders: Results<Reminder>?
    fileprivate var _userRemindersForCategory: Results<Reminder>?
    fileprivate var _selectedDuration: InputBarDuration?
    
    var reminderNotif: [BluepinNotification]? {
        get {
            return _reminderNotif
        }
        
        set(reminder) {
            _reminderNotif = reminder
        }
    }

    var realmReminder: Reminder? {
        get {
            return _realmReminder
        }
        
        set(reminder) {
            _realmReminder = reminder
        }
    }
    
    var selectedCategory: Category? {
        get {
            return _selectedCategory
        }
        
        set(category) {
            _selectedCategory = category
        }
    }
    
    var userCategories: Results<Category>? {
        get {
            return _userCategories
        }
        
        set(categories) {
            _userCategories = categories
        }
    }
    
    var userReminders: Results<Reminder>? {
        get {
            return _userReminders
        }
        
        set(reminders) {
            _userReminders = reminders
        }
    }
    
    var userRemindersForCategory: Results<Reminder>? {
        get {
            return _userRemindersForCategory
        }
        
        set(reminders) {
            _userRemindersForCategory = reminders
        }
    }
    
    var selectedDuration: InputBarDuration? {
        get {
            return _selectedDuration
        }
        
        set(duration) {
            _selectedDuration = duration
        }
    }
    
    fileprivate var persistedReminderGroup: [BluepinNotification] = [BluepinNotification]()

    func saveReminder(reminder: Reminder, category: Category) {
        do {
            try realm.write {
                realm.add(reminder, update: true)
                category.reminders.append(reminder)
            }
        } catch {
            print("Error saving items \(error)")
        }
    }
    
    
    func createReminder(name: String = NoTitle,
                        desc: String = NoDesc,
                        groupID: String = NoGroupID,
                        repeatFormat: String,
                        triggerDate: Date = Date(),
                        repeatMethod: RepeatMethod,
                        repeatInterval: Int,
                        weekdaySet: IndexSet = [1,2],
                        completionHandler: (Bool) -> Void) {
        
        guard let reminder = UNService.shared.reminder(withTitle: name,
                                                       body: repeatFormat,
                                                       startingDate: triggerDate,
                                                       repeatMethod: repeatMethod,
                                                       repeatInterval: repeatInterval,
                                                       weekdaySet: weekdaySet,
                                                       groupIdentifer: groupID),
              let ID = reminder.last?.notificationInfo.identifier,
              let nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate() else {
                
            completionHandler(false)
            return
        }
        
        let realmReminder = Reminder()
        realmReminder.ID = ID
        realmReminder.name = name
        realmReminder.reminderDescription = desc
        realmReminder.repeatMethod = repeatMethod.rawValue
        realmReminder.repeatInterval = repeatInterval
        realmReminder.nextReminder = nextReminder
        
        self.reminderNotif = reminder
        self.realmReminder = realmReminder
        
        completionHandler(true)
    }
    
    func updateReminder(reminder: [BluepinNotification]?,
                        title: String?,
                        desc: String? = NoDesc,
                        completionHandler: (Bool) -> Void) {
        
        guard realmReminder != nil, reminder != nil, title != nil, desc != nil else {
            completionHandler(false)
            return
        }
        
        for notification in reminder! {
            notification.title = title
        }
    
        self.reminderNotif = reminder
        
        self.realmReminder?.name = title!
        self.realmReminder?.reminderDescription = desc!
        
        completionHandler(true)
    }
    
    //Returns a groupID if this reminder was previously set or NoGroupID
    func groupID(from reminder: Reminder?) -> String {
        
        guard let rem = reminder else {
            return NoGroupID
        }
        
        var groupID = NoGroupID
        
        //Check if this reminder was set before and if so cancel it and remove it from the queue as it will be rescheuled and reinserted
        persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == rem.ID }

        if persistedReminderGroup.count > 0 {
            groupID = persistedReminderGroup.first?.notificationInfo.identifier ?? NoGroupID //GroupID is specified in notifInfo
        }
            
        return groupID;
    }
    
    //If a reminder is being updated, this deletes the previo notifications from the scheduler and queue
    func deletePreviousNotifications() {
        
        if persistedReminderGroup.count > 0 {
            
            for notification in persistedReminderGroup {
                
                UNService.shared.cancel(notification: notification)
                NotificationPersistedQueue.shared.remove(notification)
            }
            
        }
    }
    
    func postponeReminder(reminder: Reminder, completionHandler: (Bool) -> Void) {
        
        //Check if this reminder was set before and if so cancel it and remString(describing: ove it from the queue as it will b)e rescheuled and reinserted
        let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == reminder.ID }
        
        if persistedReminderGroup.count > 0 {
            
            guard let category = userCategories?.filter("ANY reminders.ID = '\(reminder.ID)'").first else { return }
            
            guard let notification = persistedReminderGroup.first else { return }
            
            NotificationPersistedQueue.shared.remove(notification)
            
            let trigger = UNService.shared.trigger(forStartingDate: notification.date, repeatMethod: RepeatMethod.daily, repeatInterval: 1, weekdaySet: IndexSet([1, 2]))
            
            notification.repeatTrigger = trigger
            notification.date = trigger.nextTriggerDate()
            notification.notificationInfo.date = trigger.nextTriggerDate()!
            
            var _ = UNService.shared.reschedule(notification: notification)
            
            do {
                try realm.write {
                    reminder.nextReminder = trigger.nextTriggerDate()
                    realm.add(reminder, update: true)
                    category.reminders.append(reminder)
                }
            } catch {
                print("Error saving items \(error)")
            }
            
            completionHandler(true)
        }
        
    }
}
