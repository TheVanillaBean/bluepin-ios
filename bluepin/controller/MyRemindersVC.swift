//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

class MyRemindersVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert])
        
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
//
//        UNService.shared.cancelAll()
//
//        var components = DateComponents()
//        components.second = 0
//
//        let notification = BluepinNotification(body: "This is a test notification")
//        notification.title = "This is a test title"
//        notification.badge = 5
//
//
//        let retrievedNotification = UNService.shared.notification(withIdentifier: notification.identifier)
//
//        print("\(retrievedNotification?.title)")
//
        
//        let date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
////        let reminders = UNService.shared.reminder(withBody: "body", startingDate: date!, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5]))
////        if let reminderNotifs = reminders {
////            NotificationPersistedQueue.shared.insert(reminderNotifs)
////            let _ = NotificationPersistedQueue.shared.save()
////        }
//
//        let _  = NotificationPersistedQueue.init()
//        for notification in NotificationPersistedQueue.shared.notificationsQueue() {
//            print("Reminder FireDate: \(notification)")
////            print("FireDate: Weekday: \(notification.date.inDefaultRegion().weekdayName)")
//        }
//
//
        
        let date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: "Title: ", body: "Body: ", startingDate: date!, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5, 6]))
        if let reminderNotifs = reminders {
           let _ = UNService.shared.schedule(notification: reminderNotifs.first!)
        }
        
    }
    

}

