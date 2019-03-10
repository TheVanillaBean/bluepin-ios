//
//  OnceConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import SwiftDate
import RealmSwift

class OnceConfigVC: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedReminder = UNService.shared.selectedReminder {
            configureViews(wihReminder: selectedReminder)
        }
    }
    
    func configureViews(wihReminder reminder: Reminder){
        self.datePicker.setDate(reminder.nextReminder?.date ?? Date(), animated: true)
        self.dateLbl.text = reminder.nextReminder?.date.relativeFormat() ?? Date().relativeFormat()
    }
    
    func saveReminder(reminder: Reminder, category: Category) {
        do {
            try realm.write {
                realm.add(reminder, update: true)
                category.reminders.append(reminder)
            }
        } catch {
            print("Error saving items \(error)")
        }
    }
    
    @IBAction func onceBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 0), animated: true)
    }
    
    @IBAction func dailyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 1), animated: true)
    }
    
    @IBAction func weeklyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 2), animated: true)
    }
    
    @IBAction func monthlyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 3), animated: true)
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        
        guard let selectedReminder = UNService.shared.selectedReminder else  {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        var groupID = NoGroupID
        
        //Check if this reminder was set before and if so cancel it and remove it from the queue as it will be rescheuled and reinserted
        let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == selectedReminder.ID }
        
        if persistedReminderGroup.count > 0 {
            groupID = persistedReminderGroup.first?.notificationInfo.identifier ?? NoGroupID //GroupID is specified in notifInfo
        }
        
        guard let reminder = UNService.shared.reminder(withTitle: selectedReminder.name, body: Reminder.repeatFormat(withMethod: .once, repeatInterval: 0), startingDate: datePicker.date, groupIdentifer: groupID) else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let realmReminder = Reminder()
        realmReminder.ID = (reminder.last?.notificationInfo.identifier)!
        realmReminder.name = selectedReminder.name
        realmReminder.reminderDescription = selectedReminder.reminderDescription
        realmReminder.repeatMethod = RepeatMethod.once.rawValue
        realmReminder.repeatInterval = 0
        realmReminder.nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate()
        
        if persistedReminderGroup.count > 0 {
            
            for notification in persistedReminderGroup {
                
                UNService.shared.cancel(notification: notification)
                NotificationPersistedQueue.shared.remove(notification)
            }
            
        }
        
        saveReminder(reminder: realmReminder, category: UNService.shared.selectedCategory!)
        
        UNService.shared.schedule(notifications: reminder) //Make inserting into the queue part of this function
        
        UNService.shared.selectedReminder = realmReminder
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        dateLbl.text = datePicker.date.relativeFormat()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
