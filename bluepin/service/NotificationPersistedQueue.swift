//
//  NotificationQueue.swift
//  bluepin
//
//  Created by Alex on 6/27/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import Foundation

public class NotificationPersistedQueue: NSObject {
    
    fileprivate var notifQueue = SortedArray<BluepinNotification> { $0.date < $1.date }
    let ArchiveURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("notifications.json")
    
    fileprivate static let instance = NotificationPersistedQueue()
    public static var shared: NotificationPersistedQueue {
        return self.instance
    }
    
    override init() {
        super.init()
        if let notificationQueue = self.load() {
            let sortedArrray = SortedArray<BluepinNotification> (sorted: notificationQueue) { $0.date < $1.date }
            notifQueue = sortedArrray
        }
    }
    
    public func insert(_ notifications: [BluepinNotification]) {
        for notif in notifications {
            notifQueue.insert(notif)
        }
    }
    
    public func insert(_ notification: BluepinNotification) {
        notifQueue.insert(notification)
    }
    
    public func clear() {
        notifQueue.removeAll()
    }
    
    public func remove(_ element: BluepinNotification) {
        notifQueue.remove(element)
        let _ = saveQueue()
    }
    
    public func count() -> Int {
        return notifQueue.count
    }
    
    public func notificationsQueue() -> SortedArray<BluepinNotification> {
        let queue = notifQueue
        return queue
    }
    
    public func notificationWithIdentifier(_ identifier: String) -> BluepinNotification? {
        for note in notifQueue {
            if note.identifier == identifier {
                return note
            }
        }
        return nil
    }
    
    public func saveQueue() -> Bool {
        return NotificationPersistedQueue.shared.save()
    }
    
    public func printQueue() {
        for notif in notifQueue {
            print("Notification: Title - \(notif.title) -- Date - \(notif.date) -- Scheduled - \(notif.scheduled)")
            print("---")
        }
    }
    
    private func save() -> Bool {
        let encoder = JSONEncoder()
        let encodedQueue = try! encoder.encode(self.notifQueue.elements)
        return NSKeyedArchiver.archiveRootObject(encodedQueue, toFile: ArchiveURL.path)
    }
    
    private func load() -> [BluepinNotification]? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? Data else { return nil }
        do {
            let notifications = try JSONDecoder().decode([BluepinNotification].self, from: data)
            return notifications
        } catch {
            print("Retrieve Failed")
            return nil
        }
    }
}
