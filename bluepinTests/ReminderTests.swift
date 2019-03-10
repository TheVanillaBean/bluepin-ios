//
//  ReminderTests.swift
//  bluepinTests
//
//  Created by Alex on 6/12/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import XCTest
import SwiftDate
@testable import bluepin

class ReminderTests: XCTestCase {
    
    var body: String!
    var title: String!
    var date: Date!
    
    override func setUp() {
        super.setUp()
        body = "Bluepin Reminder"
        title = "Reminder Title"
    }
    
    override func tearDown() {
        date = nil
        title = ""
        body = ""
        super.tearDown()
    }
    
    //--------------ONCE-------------------

    func testReminderRepeatOnce1(){
        date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
        let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 1.days)
        print("Reminder FireDate: \(reminder![0].date.inDefaultRegion())")
        
        XCTAssertTrue(reminder?.count == 1)
    }
    
    func testReminderRepeatOnce2(){
        date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 1.months + 13.days)
        print("Reminder FireDate: \(reminder![0].date.inDefaultRegion())")
        
        XCTAssertTrue(reminder?.count == 1)
    }
    
    //--------------DAILY------------------
    
    func testReminderDaily1(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 5.days, repeatMethod: .daily, repeatInterval: 5)

        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
        }
        XCTAssertTrue(reminders?.count == 7)
    }
    
    func testReminderDaily2() {
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .daily, repeatInterval: 3)
        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
        }
        XCTAssertTrue(reminders?.count == 7)
    }
    
    func testReminderDaily3(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .daily, repeatInterval: 5)
        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
        }
        XCTAssertTrue(reminders?.count == 7)
    }
    
    func testReminderDaily4(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 2.days, repeatMethod: .daily, repeatInterval: 3)

        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
        }
        XCTAssertTrue(reminders?.count == 7)
    }
    
    //--------------WEEKLY-------------------

    func testReminderWeekly1(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 5.days, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([2, 4]))

        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
        }
        XCTAssertTrue(reminders?.count == 2)
    }
    
    func testReminderWeekly2(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5]))

        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
        }
        XCTAssertTrue(reminders?.count == 2)
    }
    
    func testReminderWeekly3(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 2, weekdaySet: IndexSet([1, 2, 7]))
        
        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
        }
        XCTAssertTrue(reminders?.count == 3)
    }

    func testReminderWeekly4(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3]))

        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
            print("FireDate: Weekday: \(notifcation.description)")
        }
        XCTAssertTrue(reminders?.count == 1)
    }
    
    //--------------MONTHLY-------------------

    func testReminderMonthly1(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 5.days, repeatMethod: .monthly, repeatInterval: 3)
        
        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
        }
        XCTAssertTrue(reminders?.count == 1)
    }
    
    func testReminderMonthly2(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        let reminders = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .monthly, repeatInterval: 3)
        
        for notifcation in reminders! {
            print("Reminder FireDate: \(notifcation.date.inDefaultRegion())")
            print("FireDate: Weekday: \(notifcation.date.inDefaultRegion().weekdayName)")
        }
        XCTAssertTrue(reminders?.count == 1)
    }
    
    //--------------SCHEDULE----------------
    
//    func testReminderWeeklyPersisted(){
//        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
//        let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date + 1.months + 13.days)
//
//        let reminders = UNService.shared.reminder(withBody: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5]))
//        NotificationPersistedQueue.shared.insert(reminders!)
//        
//        for notification in NotificationPersistedQueue.shared.notificationsQueue() {
//            print("Reminder FireDate: \(notification.date.inDefaultRegion())")
//            print("FireDate: Weekday: \(notification.date.inDefaultRegion().weekdayName)")
//        }
//        XCTAssertTrue(reminders?.count == 2)
//        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 2)
//    }
    

}
