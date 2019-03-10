//
//  ScheduleTests.swift
//  bluepinTests
//
//  Created by Alex A on 3/2/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import XCTest
import SwiftDate
@testable import bluepin

class ScheduleTests: XCTestCase {
    
    var body: String!
    var title: String!
    var date: Date!
    
    override class func setUp() {
        super.setUp()
        NotificationPersistedQueue.shared.clear()
        UNService.shared.cancelAll()
    }
    
    override class func tearDown() {
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        body = "Bluepin Reminder"
        title = "Reminder Test"
    }
    
    override func tearDown() {
        date = nil
        title = ""
        body = ""
        super.tearDown()
    }
    
    //Note these tests may be inacurate if fired before tuesday of the week because of weekly reminder test case

    //schedule seven reminders
    func testSchedule1(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
       
        guard let reminder = UNService.shared.reminder(withTitle: title, body:  Reminder.repeatFormat(withMethod: .daily, repeatInterval: 1), startingDate: date, repeatMethod: .daily, repeatInterval: 1)  else {
            return
        }
        
        UNService.shared.schedule(notifications: reminder)
        
        let scheduledCount = UNService.shared.scheduleReminders()
        
        XCTAssertTrue(reminder.count == 7) //how many notifications in reminders
        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 7) //how many notifications in persistedQueue
        XCTAssertTrue(scheduledCount == 7) //how many notifications in persistedQueue that are scheduled
        XCTAssertTrue(UNService.shared.scheduledRemindersFromQueue() == 0) //how many notifications in persistedQueue that are scheduled

    }
    
    //schedule three more reminders
    func testSchedule2(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        
        guard let reminder = UNService.shared.reminder(withTitle: title, body:  Reminder.repeatFormat(withMethod: .daily, repeatInterval: 1), startingDate: date + 5.days, repeatMethod: .daily, repeatInterval: 1)  else {
            return
        }
        
        UNService.shared.schedule(notifications: reminder)
        
        let scheduledCount = UNService.shared.scheduleReminders()
        
        XCTAssertTrue(reminder.count == 7) //how many notifications in reminders
        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 14) //how many notifications in persistedQueue
        XCTAssertTrue(scheduledCount == 10) //how many notifications in persistedQueue that are scheduled
        XCTAssertTrue(UNService.shared.scheduledRemindersFromQueue() == 0) //how many notifications in persistedQueue that are scheduled
    }
    
    //schedule two more reminders
    func testSchedule3(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        
        guard let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([3, 5])) else {
            return
        }
        
        UNService.shared.schedule(notifications: reminder)
        
        let scheduledCount = UNService.shared.scheduleReminders()
        
        XCTAssertTrue(reminder.count == 2) //how many notifications in reminders
        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 16) //how many notifications in persistedQueue
        XCTAssertTrue(scheduledCount == 12) //how many notifications in persistedQueue that are scheduled
        XCTAssertTrue(UNService.shared.scheduledRemindersFromQueue() == 0) //how many notifications in persistedQueue that are scheduled
    }
    
    //schedule one more reminder
    func testSchedule4(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())
        
        guard let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: IndexSet([5])) else {
            return
        }
        
        UNService.shared.schedule(notifications: reminder)
        
        let scheduledCount = UNService.shared.scheduleReminders()
        
        XCTAssertTrue(reminder.count == 1) //how many notifications in reminders
        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 17) //how many notifications in persistedQueue
        XCTAssertTrue(scheduledCount == 13) //how many notifications in persistedQueue that are scheduled
        XCTAssertTrue(UNService.shared.scheduledRemindersFromQueue() == 0) //how many notifications in persistedQueue that are scheduled
    }
    
    //schedule zero more reminders
    func testSchedule5(){
        date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date() + 1.weeks)
        
        guard let reminder = UNService.shared.reminder(withTitle: title, body: body, startingDate: date, repeatMethod: .monthly, repeatInterval: 3) else {
            return
        }
        
        UNService.shared.schedule(notifications: reminder)
        
        let scheduledCount = UNService.shared.scheduleReminders()
        
        XCTAssertTrue(reminder.count == 1) //how many notifications in reminders
        XCTAssertTrue(NotificationPersistedQueue.shared.notificationsQueue().count == 18) //how many notifications in persistedQueue
        XCTAssertTrue(scheduledCount == 13) //how many notifications in persistedQueue that are scheduled
        XCTAssertTrue(UNService.shared.scheduledRemindersFromQueue() == 1) //how many notifications in persistedQueue that are scheduled
    }
}
