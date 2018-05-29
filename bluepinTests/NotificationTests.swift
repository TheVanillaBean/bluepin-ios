//
//  NotificationTests.swift
//  bluepinTests
//
//  Created by Alex on 5/27/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import XCTest
@testable import bluepin

class NotificationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotificationInitialization() {
        let body: String                    = "This is a test notification"
        let notification = BluepinNotification(body: body)
        
        //        Tests body property
        XCTAssertEqual(body, notification.body)
        
        //        Tests date property
        XCTAssertEqual(Date().next(hours: 1).removeSeconds(), notification.date.removeSeconds())
        let date: Date                      = Date()
        notification.date                   = date
        XCTAssertEqual(date, notification.date)
        
        //        Tests repeats property
        XCTAssertEqual(Repeats.none, notification.repeats)
        let repeats: Repeats                = Repeats.month
        notification.repeats                = repeats
        XCTAssertEqual(repeats, notification.repeats)
        
        //        Tests title property
        XCTAssertNil(notification.title)
        let title: String                   = "Title"
        notification.title                  = title
        XCTAssertEqual(title, notification.title)
        
        //        Tests identifier property
        XCTAssertNotNil(notification.identifier)
        
        //        Tests badge property
        XCTAssertNil(notification.badge)
        let badge: NSNumber                 = 5
        notification.badge                  = badge
        XCTAssertEqual(badge, notification.badge)
        
        //        Tests userInfo property
        let userInfo: [AnyHashable : Any]   = [BluepinNotification.identifierKey : notification.identifier, BluepinNotification.dateKey : notification.date]
        XCTAssertEqual(userInfo[BluepinNotification.identifierKey] as! String, notification.userInfo![BluepinNotification.identifierKey] as! String)
        XCTAssertEqual(userInfo[BluepinNotification.dateKey] as! Date, notification.userInfo![BluepinNotification.dateKey] as! Date)
        
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
        let body: String                    = "This is a test notification"
        let identifier: String              = "Identifier"
        let notification = BluepinNotification(identifier: identifier, body: body)
        
        XCTAssertEqual(identifier, notification.identifier)
        XCTAssertEqual(body, notification.body)
    }
    
    // Tests whether setting a `BluepinNotification` userInfo key succeeds.
    func testNotificationUserInfoSet() {
        let notification = BluepinNotification(body: "Notification")
        
        let key: String                     = "Key"
        let value: String                   = "Value"
        notification.setUserInfo(value: value, forKey: key)
        
        XCTAssertEqual(value, notification.userInfo[key] as! String)
        
        notification.setUserInfo(value: value, forKey: BluepinNotification.identifierKey)
        
        XCTAssertNotEqual(value, notification.userInfo[BluepinNotification.identifierKey] as! String)
    }

    // Tests whether setting a `BluepinNotification` userInfo key succeeds.
    func testNotificationUserInfoRemove() {
        let notification = BluepinNotification(body: "Notification")
        
        let key: String                     = "Key"
        let value: String                   = "Value"
        notification.setUserInfo(value: value, forKey: key)
        
        notification.removeUserInfoValue(forKey: key)
        
        XCTAssertNil(notification.userInfo[key])
        
        notification.removeUserInfoValue(forKey: BluepinNotification.identifierKey)
        
        XCTAssertEqual(notification.identifier, notification.userInfo[BluepinNotification.identifierKey] as? String)
    }
    
    // Tests whether initialized BluepinNotifications have different identifiers.
    func testNotificationNonEquality() {
        let firstNotification = BluepinNotification(body: "First Notification")
        let secondNotification = BluepinNotification(body: "Second Notification")
        
        let notEqual: Bool                        = firstNotification == secondNotification
        
        XCTAssertFalse(notEqual)
    }
    
    // Tests whether testing for notification date precedence succeeds.
    func testNotificationDatePrecedence() {
        let firstNotification = BluepinNotification(body: "First Notification", date: Date().next(minutes: 10))
        let secondNotification = BluepinNotification(body: "Second Notification", date: Date().next(hours: 1))
        
        let precedes: Bool                        = firstNotification < secondNotification
        
        XCTAssertTrue(precedes)
        
        firstNotification.date                    = Date().next(days: 1)
        
        let doesNotPrecede: Bool                  = firstNotification < secondNotification
        
        XCTAssertFalse(doesNotPrecede)
    }
}




