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

internal let MAX_ALLOWED_NOTIFICATIONS = 60

public class UNService: NSObject {
    
    private override init() {}
    
    fileprivate static let instance = UNService()
    
    public static var shared: UNService {
        return self.instance
    }

    let unCenter = UNUserNotificationCenter.current()

    func requestAuthorization(forOptions options: NotificationAuthorizationOptions) {
        let authorizationOptions: UNAuthorizationOptions = UNAuthorizationOptions(rawValue: options.rawValue)
        
        unCenter.requestAuthorization(options: authorizationOptions) { (granted, error) in
            print(error ?? "Successfully Requested Authorization for Local Notifications")
            guard granted else {
                print("User Denied Access for Notifications")
                return
            }
            
            self.unCenter.delegate = self //configure
        }
        
    }

    private func trigger(forDate date: Date, repeats: Repeats) -> UNCalendarNotificationTrigger {
        var dateComponents: DateComponents = DateComponents()
        let shouldRepeat: Bool             = repeats != .none
        let calendar: Calendar             = Calendar.current
        
        switch repeats {
        case .none:
            dateComponents                 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        case .month:
            dateComponents                 = calendar.dateComponents([.day, .hour, .minute], from: date)
        case .week:
            dateComponents.weekday         = calendar.component(.weekday, from: date)
            fallthrough
        case .day:
            dateComponents.hour            = calendar.component(.hour, from: date)
            fallthrough
        case .hour:
            dateComponents.minute          = calendar.component(.minute, from: date)
            dateComponents.second          = 0
        }
        
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: shouldRepeat)
    }
    
    private func weekday(weekdaySet: IndexSet, date: Date) -> Date{
        let calendar = Calendar.current
        var weekday =  calendar.component(.weekday, from: date)
        
        if let nextWeekday = weekdaySet.integerGreaterThan(weekday) {
            weekday = nextWeekday
        } else {
            weekday = weekdaySet.first!
        }
        
        var components = calendar.dateComponents([.hour, .minute], from: date)
        components.weekday = weekday
        
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)!
    }
    
    
    private func trigger(forStartingDate date: Date, repeatMethod: RepeatMethod, repeatInterval: Int, weekdaySet: IndexSet) -> UNCalendarNotificationTrigger {
        
        var dateComponents: DateComponents = DateComponents()
        let calendar: Calendar = Calendar.current
        var nextFireDate: Date!
        
        if repeatMethod == .daily {
            nextFireDate = date + repeatInterval.days
        }
        
        if repeatMethod == .monthly {
            nextFireDate = date + repeatInterval.months
        }
        
        if repeatMethod == .weekly {
            nextFireDate = weekday(weekdaySet: weekdaySet, date: date)
        }
        
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextFireDate)
        dateComponents.second = 0
        
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }
    
    func reminder(withBody body: String, startingDate: Date, repeatMethod: RepeatMethod = .once, repeatInterval: Int = 0, weekdaySet: IndexSet = IndexSet([1, 2])) -> [BluepinNotification]? {
        
        let identifer: String = UUID().uuidString
        
        if repeatMethod == .once {
            let notification = BluepinNotification(identifier: "\(identifer)", body: body, date: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nil)
            return [notification]
        }
        
        if startingDate >= Date() + 4.days {
            let notification = BluepinNotification(identifier: "\(identifer)_1", body: body, date: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nil)
            return [notification]
        }
        
        var notifications = [BluepinNotification]()
        
        
        if repeatMethod == .daily && repeatInterval < 4 {
            
            var startDate = startingDate < Date() + 5.minutes ? startingDate + repeatInterval.day : startingDate
            
            let notification = BluepinNotification(identifier: "\(identifer)_1", body: body, date: startDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nil)
            notifications.append(notification)

            startDate = (notification.repeatTrigger?.nextTriggerDate())!

            for i in 2...4 {
                let nextFireDate = trigger(forStartingDate: startDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
                let notification = BluepinNotification(identifier: "\(identifer)_\(i)", body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate)
                notifications.append(notification)
                startDate = nextFireDate.nextTriggerDate()!
            }
            
        } else if repeatMethod == .weekly && weekdaySet.count > 1 {
            
            var startDate = startingDate + (repeatInterval - 1).weeks

            for i in 1...weekdaySet.count {
                let nextFireDate = trigger(forStartingDate: startDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
                let notification = BluepinNotification(identifier: "\(identifer)_\(i)", body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate)
                notifications.append(notification)
                startDate = nextFireDate.nextTriggerDate()!
            }
            
        } else {
            let nextFireDate = trigger(forStartingDate: startingDate, repeatMethod: repeatMethod, repeatInterval: repeatInterval, weekdaySet: weekdaySet)
            let notification = BluepinNotification(identifier: "\(identifer)_1", body: body, date: nextFireDate.nextTriggerDate()!, repeatMethod: repeatMethod, repeatInterval: repeatInterval, repeatTrigger: nextFireDate)
            notifications.append(notification)
        }
                
        return notifications
        
    }
    
    func schedule(notification: BluepinNotification) -> BluepinNotification? {
        if notification.scheduled == true {
            return nil
        }
        
        if (self.scheduledCount() >= MAX_ALLOWED_NOTIFICATIONS) {
            return nil
        }
        
        let content                                = UNMutableNotificationContent()
        
        if let title                               = notification.title {
            content.title                          = title
        }
        
        content.body                               = notification.body
        
        var sound: UNNotificationSound             = UNNotificationSound.default()
        if let name = notification.sound.name {
            if name != BluepinNotification.defaultSoundName {
                sound                              = UNNotificationSound(named: name)
            }
        } else {
            if let notificationSound = notification.sound.sound {
                sound                              = notificationSound
            }
        }
        content.sound                              = sound
        
        content.userInfo                           = notification.userInfo
        
        content.badge                              = notification.badge
        
        let trigger = self.trigger(forDate: notification.date, repeats: notification.repeats)
        
        let request: UNNotificationRequest         = UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger)
        unCenter.add(request, withCompletionHandler: nil)
        notification.scheduled                     = true
        
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
    
    //    MARK:- Testing
    
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
    
    
}

extension UNService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UN did receive response")
        
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("UN WILL present")
        
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(options)
    }
}
