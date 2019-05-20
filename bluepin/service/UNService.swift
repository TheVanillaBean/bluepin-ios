//
//  UNService.swift
//  bluepin
//
//  Created by Alex on 5/18/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftDate
import RealmSwift

internal let MAX_ALLOWED_NOTIFICATIONS = 64

public class UNService: NSObject {
    
    private override init() {}
    
    fileprivate static let instance = UNService()
    
    public static var shared: UNService {
        return self.instance
    }

    let unCenter = UNUserNotificationCenter.current()
    
    //------------------------------------
    
    var _selectedReminder: Reminder?
    
    var selectedReminder: Reminder? {
        get {
            return _selectedReminder
        }
        
        set(reminder) {
            _selectedReminder = reminder
        }
    }
    
    var _selectedCategory: Category?
    
    var selectedCategory: Category? {
        get {
            return _selectedCategory
        }
        
        set(category) {
            _selectedCategory = category
        }
    }
    
    var _userCategories: Results<Category>?
    
    var userCategories: Results<Category>? {
        get {
            return _userCategories
        }
        
        set(categories) {
            _userCategories = categories
        }
    }
    
    var _userReminders: Results<Reminder>?
    
    var userReminders: Results<Reminder>? {
        get {
            return _userReminders
        }
        
        set(reminders) {
            _userReminders = reminders
        }
    }
    
    var _selectedDuration: InputBarDuration?
    
    var selectedDuration: InputBarDuration? {
        get {
            return _selectedDuration
        }
        
        set(duration) {
            _selectedDuration = duration
        }
    }
    
    var _reminderForInputBar: [BluepinNotification]?
    
    var reminderForInputBar: [BluepinNotification]? {
        get {
            return _reminderForInputBar
        }
        
        set(reminder) {
            _reminderForInputBar = reminder
        }
    }
    
    var _realmReminderForInputBar: Reminder?
    
    var realmReminderForInputBar: Reminder? {
        get {
            return _realmReminderForInputBar
        }
        
        set(reminder) {
            _realmReminderForInputBar = reminder
        }
    }


    //-----------------------------------
    
    func requestAuthorization(forOptions options: NotificationAuthorizationOptions, completionHandler: @escaping (Bool) -> Void) {
        let authorizationOptions: UNAuthorizationOptions = UNAuthorizationOptions(rawValue: options.rawValue)
        
        unCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
            print(error ?? "Successfully Requested Authorization for Local Notifications")
            guard granted else {
                print("User Denied Access for Notifications")
                DispatchQueue.main.async {
                    completionHandler(false)
                }
                return
            }
            self.assignDelegate()
            DispatchQueue.main.async {
                completionHandler(true)
            }
        }
        
    }
    
    func assignDelegate() {
        self.unCenter.delegate = self
    }
    
    private func weekday(weekdaySet: IndexSet, date: Date) -> Date{
        
        let calendar = Calendar.current
        var weekday = calendar.component(.weekday, from: date)
        
        weekday = weekdaySet.integerGreaterThan(weekday) ?? weekdaySet.first!
        
        var components = calendar.dateComponents([.hour, .minute], from: date)
        components.weekday = weekday + 1
    
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)!
    }
    
    public func trigger(forStartingDate date: Date, repeatMethod: RepeatMethod, repeatInterval: Int, weekdaySet: IndexSet) -> UNCalendarNotificationTrigger {
        
        var dateComponents: DateComponents = DateComponents()
        let calendar: Calendar = Calendar.current
        var nextFireDate: Date!
        
        switch repeatMethod {
            case .daily:
                nextFireDate = date + repeatInterval.days
            case .weekly:
                nextFireDate = weekday(weekdaySet: weekdaySet, date: date)
            case .monthly:
                nextFireDate = date + repeatInterval.months
            case .once:
                nextFireDate = date
        }
        
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextFireDate)
//        dateComponents.second = 0
        
        
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }

    func reminder(withTitle title: String, body: String, startingDate: Date, repeatMethod: RepeatMethod = .once, repeatInterval: Int = 0, weekdaySet: IndexSet = IndexSet([1, 2]), groupIdentifer: String = UUID().uuidString) -> [BluepinNotification]? {
        
        let identifer: String = groupIdentifer == NoGroupID ? UUID().uuidString : groupIdentifer
        
        //Create a group of notifications (representing one reminder) that will either be all scheduled, partially scheduled, not scheduled, and all will be added to NotificationPersistedQueue
        var notifications = [BluepinNotification]()
        
        //----ONCE -----//
        if repeatMethod == .once {
            let nextFireDate = trigger(forStartingDate: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
        
            let notification = BluepinNotification(identifier: "\(identifer)", groupIdentifier: identifer, title: title, body: body, date: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate)
            notifications.append(notification)
            
        //----DAILY -----//
        } else if repeatMethod == .daily {
            
            /* if starting date is not the current date (+ 3.minutes - arbitrary - because technically even if a second goes by then it will always be true), subtract the repeat days
             because they will be added back anyways
             */
            var startDate = startingDate > Date() + 3.minutes ? startingDate - repeatInterval.days : startingDate

            for i in 1...7 {
                let nextFireDate = trigger(forStartingDate: startDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
                let notification = BluepinNotification(identifier: "\(identifer)_\(i)", groupIdentifier: identifer, title: title, body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate)
                notifications.append(notification)
                startDate = nextFireDate.nextTriggerDate()!
            }
        
        //----Weekly -----//
        } else if repeatMethod == .weekly {
            
            var startDate = startingDate + (repeatInterval - 1).weeks
            
            for i in 1...weekdaySet.count {
                print("\(startDate)  --StartDate")
                let nextFireDate = trigger(forStartingDate: startDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
                let notification = BluepinNotification(identifier: "\(identifer)_\(i)", groupIdentifier: identifer, title: title, body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate, weekdaySet: weekdaySet)
                notifications.append(notification)
                startDate = nextFireDate.nextTriggerDate()!
            }
            
        //----MONTHLY -----//
        } else if repeatMethod == .monthly {
            
            let nextFireDate = trigger(forStartingDate: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
            let notification = BluepinNotification(identifier: "\(identifer)_1", groupIdentifier: identifer, title: title, body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate, weekdaySet: weekdaySet)
            notifications.append(notification)
            
        }
                
        return notifications
        
    }
    
    func schedule(notifications: [BluepinNotification]){
        for notification in notifications {
            _ = self.schedule(notification: notification)
        }
    }
    
    func schedule(notification: BluepinNotification) -> BluepinNotification? {
        if notification.scheduled == true {
            return nil
        }
        
        if let triggerDate = notification.repeatTrigger?.nextTriggerDate() {
            if triggerDate >  Date() + 2.weeks {
                NotificationPersistedQueue.shared.insert(notification)
                let _ = NotificationPersistedQueue.shared.saveQueue()
                return nil
            }
        }
        
        if (self.scheduledCount() >= MAX_ALLOWED_NOTIFICATIONS) {
            NotificationPersistedQueue.shared.insert(notification)
            let _ = NotificationPersistedQueue.shared.saveQueue()
            return nil
        }
        
        let content                                = UNMutableNotificationContent()
        
        if let title                               = notification.title {
            content.title                          = title
        }
        
        content.body                               = notification.body
        
        var sound: UNNotificationSound             = UNNotificationSound.default
        if let name = notification.sound.name {
            if name != DefaultSoundName {
                sound                              = UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
            }
        } else {
            if let notificationSound = notification.sound.sound {
                sound                              = notificationSound
            }
        }
        content.sound                              = sound
        
        content.userInfo                           = notification.notificationDictionary()
        
        content.badge                              = notification.badge
        
        
        let trigger                                = notification.repeatTrigger
        
        let request: UNNotificationRequest         = UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger)
        
        unCenter.add(request, withCompletionHandler: nil)
        
        notification.scheduled                     = true
        
        NotificationPersistedQueue.shared.insert(notification)
        let _ = NotificationPersistedQueue.shared.saveQueue()
        
        return notification
       
    }
    
    func reschedule(notification: BluepinNotification) -> BluepinNotification? {
        self.cancel(notification: notification)
        
        return self.schedule(notification: notification)
    }
    
    func cancel(notification: BluepinNotification) {
        if notification.scheduled == false {
            return
        }
        
        unCenter.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
        notification.scheduled = false
    }
    
    func cancel(withIdentifier identifier: String) {
        unCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAll() {
        unCenter.removeAllPendingNotificationRequests()
        print("All scheduled system notifications have been canceled.")
    }
    
    func notification(withIdentifier identifier: String) -> BluepinNotification? {
        let semaphore                         = DispatchSemaphore(value: 0)
        var notification: BluepinNotification?  = nil
        
        unCenter.getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == identifier {
                    notification = BluepinNotification.notification(withRequest: request)
                    
                    semaphore.signal()
                    
                    break
                }
            }
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return notification
    }
    
    func scheduledCount() -> Int {
        let semaphore                        = DispatchSemaphore(value: 0)
        var count: Int                       = 0
        
        unCenter.getPendingNotificationRequests { requests in
            count = requests.count
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return count
    }
    
    func printScheduled() {
        if (self.scheduledCount() == 0) {
            print("There are no scheduled system notifications.")
            return
        }
        
        let semaphore                        = DispatchSemaphore(value: 0)
        unCenter.getPendingNotificationRequests { requests in
            for request in requests {
                let notification: BluepinNotification = request.notification()!
                
                print(notification)
            }
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    /*
     Description: Iterates through all notification in NotificationPersistedQueue that have a trigger date
     after the current date,
     not longer than a week from current date,
     is not already scheduled.
     
     It also creates a new notification of the same group identifier family and appends it to the queue
    */
    func scheduleReminders(_ date: Date = Date()) {
        //loop through all persisted notifications with trigger dates after the current date
        for notification in NotificationPersistedQueue.shared.notificationsQueue().filter({ $0.scheduled == false && $0.date > date && $0.date < date + 1.weeks}) {
            let  _ = UNService.shared.schedule(notification: notification) //schedule the notification
            
            let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == notification.notificationInfo.identifier }
            guard let lastNotification = persistedReminderGroup.last else { return }

            if let newNotification = appendNotification(notification: lastNotification) {
                let _ = UNService.shared.schedule(notification: newNotification)
            }
            
        }
        
    }
    
    //Helper function to create new notification based on a previous notification (the last of the batch)
    func appendNotification(notification: BluepinNotification) -> BluepinNotification? {
        
        guard let startDate = notification.repeatTrigger?.nextTriggerDate() else { return nil}
        guard let title = notification.title else { return nil }
        
        var weekdaySet = IndexSet([1, 2]) //default
        
        if let set = notification.notificationInfo.repeatWeekdayInterval{
            weekdaySet = set //if repeat method is weekly
        }
        
        let identifier = notification.identifier.iterateIdentifier()
        
        let nextFireDate = UNService.shared.trigger(forStartingDate: startDate, repeatMethod: notification.repeatMethod, repeatInterval: notification.repeatInterval, weekdaySet: weekdaySet)
        let notification = BluepinNotification(
            identifier: "\(identifier)",
            groupIdentifier: notification.notificationInfo.identifier,
            title: title,
            body: notification.body,
            date: nextFireDate.nextTriggerDate()!,
            repeatMethod: notification.repeatMethod,
            repeatInterval: notification.repeatInterval,
            repeatTrigger: nextFireDate,
            weekdaySet: weekdaySet)
        
        return notification
    }
    
}

extension UNService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UN did receive response")
        
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("UN WILL present")
        
        let options: UNNotificationPresentationOptions = [.alert, .badge, .sound]
        completionHandler(options)
    }
}
