//
//  NotificationScheduleTests.swift
//  bluepinTests
//
//  Created by Alex on 5/27/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import XCTest
@testable import bluepin

class NotificationScheduleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UNService.shared.cancelAll()
    }
    
    override func tearDown() {
        UNService.shared.cancelAll()
        super.tearDown()
    }
    
    func testNotificationSchedule() {
        let notification          = BluepinNotification(body: "This is a test notification")
        
        let scheduledNotification = UNService.shared.schedule(notification: notification)
        
        XCTAssertNotNil(scheduledNotification)
        XCTAssertTrue(notification.scheduled)
        XCTAssertTrue(scheduledNotification!.scheduled)
        XCTAssertEqual(1, UNService.shared.scheduledCount())
    }
    
    /// Tests whether scheduling multiple `BluepinNotification`s succeeds.
    func testNotificationMultipleSchedule() {
        let count: Int = 15
        for i in 0 ..< count {
            let notification = BluepinNotification(body: "This is test notification #\(i + 1)")
            
            let _ = UNService.shared.schedule(notification: notification)
        }
        
        XCTAssertEqual(count, UNService.shared.scheduledCount())
    }
    
    /// Tests whether scheduling a `BluepinNotification` beyond the allowed maximum succeeds.
    func testNotificationScheduleOverAllowed() {
        let count: Int = MAX_ALLOWED_NOTIFICATIONS
        for i in 0 ..< count {
            let notification = BluepinNotification(body: "This is test notification #\(i + 1)")
            
            let _ = UNService.shared.schedule(notification: notification)
        }
        
        let notification = BluepinNotification(body: "This is an overflow notification")
        
        let overflowNotification = UNService.shared.schedule(notification: notification)
        
        XCTAssertNil(overflowNotification)
        XCTAssertFalse(notification.scheduled)
        XCTAssertEqual(count, UNService.shared.scheduledCount())
    }
    
    /// Tests whether rescheduling a `BluepinNotification` beyond the allowed maximum succeeds.
    func testNotificationReschedule() {
        let date: Date              = Date().next(days: 1).removeSeconds()
        let notification            = BluepinNotification(body: "This is a test notification")
        
        let _                       = UNService.shared.schedule(notification: notification)
        
        notification.date           = date
        
        let _                       = UNService.shared.reschedule(notification: notification)
        
        let rescheduledNotification = UNService.shared.notification(withIdentifier: notification.identifier)
        
        XCTAssertNotNil(rescheduledNotification)
        XCTAssertTrue(rescheduledNotification!.scheduled)
        XCTAssertEqual(rescheduledNotification!.date, notification.date)
        XCTAssertEqual(1, UNService.shared.scheduledCount())
    }
    
    /// Tests whether canceling a scheduled system notification succeeds.
    func testNotificationCancel() {
        let notification          = BluepinNotification(body: "This is a test notification")
        
        let scheduledNotification = UNService.shared.schedule(notification: notification)
        
        UNService.shared.cancel(notification: scheduledNotification!)
        
        XCTAssertNotNil(scheduledNotification)
        XCTAssertFalse(notification.scheduled)
        XCTAssertFalse(scheduledNotification!.scheduled)
        XCTAssertEqual(0, UNService.shared.scheduledCount())
    }
    
    /// Tests whether canceling a scheduled system notification by identifier succeeds.
    func testNotificationIdentifierCancel() {
        let notification          = BluepinNotification(body: "This is a test notification")
        
        let _ = UNService.shared.schedule(notification: notification)
        
        UNService.shared.cancel(withIdentifier: notification.identifier)
        
        XCTAssertTrue(notification.scheduled)
        XCTAssertEqual(0, UNService.shared.scheduledCount())
    }
    
    /// Tests whether canceling multiple scheduled system notifications by identifier succeeds.
    func testNotificationMultipleCancel() {
        let count: Int         = 15
        let identifier: String = "IDENTIFIER"
        for i in 0 ..< count {
            let notification = BluepinNotification(identifier: identifier, body: "This is test notification #\(i + 1)")
            
            let _ = UNService.shared.schedule(notification: notification)
        }
        
        UNService.shared.cancel(withIdentifier: identifier)
        
        XCTAssertEqual(0, UNService.shared.scheduledCount())
    }
    
    /// Tests whether canceling all scheduled system notifications succeeds.
    func testCancelAll() {
        let count: Int = 15
        for i in 0 ..< count {
            let notification = BluepinNotification(body: "This is test notification #\(i + 1)")
            
            let _ = UNService.shared.schedule(notification: notification)
        }
        
        UNService.shared.cancelAll()
        
        XCTAssertEqual(0, UNService.shared.scheduledCount())
    }
    
    /// Tests whether retrieving a scheduled system notification by identifier succeeds.
    func testNotificationWithIdentifier() {
        let notification          = BluepinNotification(body: "This is a test notification")
        notification.title        = "This is a test title"
        notification.badge        = 1
        notification.repeats      = .week
        notification.sound        = NotificationSound(named: "TestSound")
        notification.setUserInfo(value: "Value", forKey: "Key")
        
        let _                     = UNService.shared.schedule(notification: notification)
        
        let retrievedNotification = UNService.shared.notification(withIdentifier: notification.identifier)
        
        XCTAssertEqual(retrievedNotification?.title, notification.title)
        XCTAssertEqual(retrievedNotification?.identifier, notification.identifier)
        XCTAssertEqual(retrievedNotification?.body, notification.body)
        XCTAssertEqual((retrievedNotification?.date.timeIntervalSinceReferenceDate)!, notification.date.timeIntervalSinceReferenceDate, accuracy: 1.0)
        XCTAssertEqual(retrievedNotification?.userInfo.count, notification.userInfo.count)
        XCTAssertEqual(retrievedNotification?.badge, notification.badge)
        XCTAssertTrue(notification.sound.isValid())
        XCTAssertEqual(retrievedNotification?.repeats, notification.repeats)
        XCTAssertEqual(retrievedNotification?.scheduled, notification.scheduled)
        XCTAssertTrue(retrievedNotification!.scheduled)
        XCTAssertEqual(1, UNService.shared.scheduledCount())
    }
    
    
}
