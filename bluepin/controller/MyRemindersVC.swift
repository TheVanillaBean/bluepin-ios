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

    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)
    
    var reminders: Results<Reminder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
                
        loadCategories()
        
    }
    
    func loadCategories() {
        UNService.shared.userCategories = realm.objects(Category.self)
        reminders = realm.objects(Reminder.self)
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReminderCategoriesVC", sender: nil)
    }

}

extension MyRemindersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRemindersCell", for: indexPath) as! MyRemindersCell
        cell.configureCell(reminder: reminder!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "goToReminderDetailVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}



    
    //        let a1 = Reminder()
    //        a1.name = "Change oil and filter"
    //        a1.reminderDescription = "Check the owner’s manual first. The oil change interval for most modern cars is: conventional oil - 3,000 to 5,000 miles, synthetic oil - 7,500 to 10,000 miles.Depending on your driving conditions, change your oil every 3-5 months."
    //        a1.repeatMethod = RepeatMethod.monthly.rawValue
    //        a1.repeatInterval = 3
    //
    //        let a2 = Reminder()
    //        a2.name = "Check tire pressure"
    //        a2.reminderDescription = "Check your tire pressure once a month when the tires are cold.  Use a tire pressure gauge. The recommended tire pressure (PSI level) can be found in your car manual, on a sticker in the door jam, on the trunk lid, in the console or on the fuel door. It usually varies between 30 and 35 PSI.Keep a small portable tire inflator in trunk at all times."
    //        a2.repeatMethod = RepeatMethod.monthly.rawValue
    //        a2.repeatInterval = 1
    //
    //        let a3 = Reminder()
    //        a3.name = "Change smoke detector batteries"
    //        a3.reminderDescription = "Smoke alarms save lives, but only when they are functioning correctly. Replace the batteries at least once a year. Replace the entire smoke alarm once every 10 years."
    //        a3.repeatMethod = RepeatMethod.monthly.rawValue
    //        a3.repeatInterval = 12
    //
    //        let a4 = Reminder()
    //        a4.name = "Mow the lawn"
    //        a4.reminderDescription = "Mow you lawn once a week. Never cut more than one third of the grass blades’s height at a time. Cutting too much can stress the grass by stealing the grass’s food-producing parts and starve the lawn. The ideal height for healthy grass is about 3” to 3.5”."
    //        a4.repeatMethod = RepeatMethod.weekly.rawValue
    //        a4.repeatInterval = 1
    //
    //
    //        saveReminder(reminder: a1, category: categories![5])
    //        saveReminder(reminder: a2, category: categories![5])
    //        saveReminder(reminder: a3, category: categories![0])
    //        saveReminder(reminder: a4, category: categories![0])
    
















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

