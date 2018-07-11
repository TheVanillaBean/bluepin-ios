//
//  NotificationTests.swift
//  bluepinTests
//
//  Created by Alex on 5/27/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import XCTest
import SwiftDate
@testable import bluepin

class NotificationTests: XCTestCase {
    
    var currentDate: Date!
    var body: String!
    var title: String!
    
    override func setUp() {
        super.setUp()
        currentDate = Date()
        body = "This is a test notification"
        title = "Notification Title"
    }
    
    override func tearDown() {
        currentDate = nil
        body = ""
        title = ""
        super.tearDown()
    }
    
    func testNotificationInitialization() {
        let notification = BluepinNotification(title: title, body: body, date: currentDate)
        
        //        Tests identifier property
        XCTAssertNotNil(notification.identifier)
        
        //        Tests title property
        XCTAssertEqual(title, notification.title)

        //        Tests body property
        XCTAssertEqual(body, notification.body)
        
        //        Tests date property
        XCTAssertEqual(currentDate.removeSeconds(), notification.date.removeSeconds())
        
        let next2Days: Date                      = currentDate + 2.days
        notification.date                   = next2Days
        
        XCTAssertEqual(next2Days, notification.date)
        //--------------------

        //        Tests badge property
        XCTAssertEqual(notification.badge, 0)
        let badge: NSNumber                 = 5
        notification.badge                  = badge
        XCTAssertEqual(badge, notification.badge)
        
        //      Tests notificationInfo property

        let notificationInfo = BPNotificationInfo()
        notificationInfo.identifier = notification.identifier
        notificationInfo.date = notification.date
        notificationInfo.repeatMethod = notification.repeatMethod
        notificationInfo.repeatInterval = notification.repeatInterval
        
        XCTAssertEqual(notificationInfo.identifier, notification.identifier)
        XCTAssertEqual(notificationInfo.date, notification.date)
        XCTAssertEqual(notificationInfo.repeatMethod, notification.repeatMethod)
        XCTAssertEqual(notificationInfo.repeatInterval, notification.repeatInterval)

        XCTAssertNil(notificationInfo.repeatWeekdayInterval)
        
        //----------------------
        
        //        Tests sound property
        XCTAssertTrue(notification.sound.isValid())
        let sound: String                   = "SoundName"
        notification.sound                  = NotificationSound(named: sound)
        XCTAssertTrue(notification.sound.isValid())
        
        //        Tests scheduled property
        XCTAssertFalse(notification.scheduled)
    }
    
    // Tests whether the initialization of `BluepinNotification` with a custom identifier succeeds.
    func testNotificationInitializationWithIdentifier() {
        let identifier: String              = "Identifier"
        let notification = BluepinNotification(identifier: identifier, title: title, body: body, date: currentDate)
        
        XCTAssertEqual(identifier, notification.identifier)
        XCTAssertEqual(body, notification.body)
        XCTAssertEqual(title, notification.title)
    }

    
    // Tests whether initialized BluepinNotifications have different identifiers.
    func testNotificationNonEquality() {
        let firstNotification = BluepinNotification(title: title, body: "First Notification", date: currentDate)
        let secondNotification = BluepinNotification(title: title, body: "Second Notification", date: currentDate)

        let notEqual: Bool                        = firstNotification == secondNotification
        
        XCTAssertFalse(notEqual)
    }
    
    // Tests whether testing for notification date precedence succeeds.
    func testNotificationDatePrecedence() {
        let firstNotification = BluepinNotification(title: title, body: "First Notification", date: currentDate + 10.minutes)
        let secondNotification = BluepinNotification(title: title, body: "Second Notification", date: currentDate + 1.hours)
        
        let precedes: Bool                        = firstNotification < secondNotification
        
        XCTAssertTrue(precedes)
        
        firstNotification.date                    = currentDate + 1.days
        
        let doesNotPrecede: Bool                  = firstNotification < secondNotification
        
        XCTAssertFalse(doesNotPrecede)
    }
    
}















