//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift

class MyRemindersVC: UIViewController {

    lazy var realm = try! Realm()
    
    var categories: Results<Category>?
    
    var reminders: Results<Reminder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert])
        
        loadCategories()
        
    }
    
    func save(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }

    }

    func saveReminder(reminder: Reminder, category: Category){
        do {
            try realm.write {
                print("Write \(reminder.name)")
                category.reminders.append(reminder)
            }
        } catch {
            print("Error saving items \(error)")
        }

    }

    func loadCategories(){
        categories = realm.objects(Category.self)
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        
        
        
    }
    

}












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

//        let date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
//        let reminders = UNService.shared.reminder(withTitle: "Title: ", body: "Body: ", startingDate: date!, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5, 6]))
//        if let reminderNotifs = reminders {
//           let _ = UNService.shared.schedule(notification: reminderNotifs.first!)
//        }

//        var home = Category()
//        home.name = "Home"
//
//        var personal = Category()
//        personal.name = "Personal"
//
//        var family = Category()
//        family.name = "Family"
//
//        var Medical = Category()
//        Medical.name = "Medical"
//
//        var Finance = Category()
//        Finance.name = "Finance"
//
//        var Automotive = Category()
//        Automotive.name = "Automotive"
//
//        var fitness = Category()
//        fitness.name = "Fitness"
//
//        var pets = Category()
//        pets.name = "Pets"
//
//        save(category: home)
//        save(category: personal)
//        save(category: family)
//        save(category: Medical)
//        save(category: Finance)
//        save(category: Automotive)
//        save(category: fitness)
//        save(category: pets)
//
//        //Auto
//
//        let a1 = Reminder()
//        a1.name = "Appt with a car mechanic"
//        a1.reminderDescription = "Description"
//        a1.repeatMethod = "Monthly"
//        a1.repeatInterval = 4
//
//        let a2 = Reminder()
//        a2.name = "Service appt at dealership"
//        a2.reminderDescription = "Description2"
//        a2.repeatMethod = "Monthly"
//        a2.repeatInterval = 12
//
//        let a3 = Reminder()
//        a3.name = "Appt at an auto body shop"
//        a3.reminderDescription = "Description3"
//        a3.repeatMethod = "Monthly"
//        a3.repeatInterval = 12
//
//        let a4 = Reminder()
//        a4.name = "Change oil and filter"
//        a4.reminderDescription = "Description4"
//        a4.repeatMethod = "Monthly"
//        a4.repeatInterval = 4
//
//        let a5 = Reminder()
//        a5.name = "Check tire pressure"
//        a5.reminderDescription = "Description5"
//        a5.repeatMethod = "Monthly"
//        a5.repeatInterval = 4
//
//        saveReminder(reminder: a1, category: categories![5])
//        saveReminder(reminder: a2, category: categories![5])
//        saveReminder(reminder: a3, category: categories![5])
//        saveReminder(reminder: a4, category: categories![5])
//        saveReminder(reminder: a5, category: categories![5])

