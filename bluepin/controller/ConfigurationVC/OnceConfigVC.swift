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
        if let reminder = UNService.shared.reminder(withTitle: (UNService.shared.selectedReminder?.name)!, body: Reminder.repeatFormat(withMethod: .once, repeatInterval: 0), startingDate: datePicker.date) {
            
            if let selectedReminder = UNService.shared.selectedReminder {
                
                let reminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == selectedReminder.ID }
                
                if reminderGroup.count > 0 {

                    do {
                        try realm.write {
                            
                            for reminder in reminderGroup {
                                
                                UNService.shared.cancel(withIdentifier: reminder.identifier)
                                NotificationPersistedQueue.shared.remove(reminder)
                            }
                            
                            NotificationPersistedQueue.shared.insert(reminder)
                            let _ = NotificationPersistedQueue.shared.saveQueue()
                            
                            UNService.shared.selectedReminder?.ID = (reminder.last?.notificationInfo.identifier)!
                            UNService.shared.selectedReminder?.repeatMethod = RepeatMethod.once.rawValue
                            UNService.shared.selectedReminder?.repeatInterval = 0
                            UNService.shared.selectedReminder?.nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate()
                            
                            UNService.shared.schedule(notifications: reminder)

                        }
                    } catch {
                        print("Error saving items \(error)")
                    }
                    
                } else {
                    let realmReminder = Reminder()
                    realmReminder.ID = (reminder.last?.notificationInfo.identifier)!
                    realmReminder.name = selectedReminder.name
                    realmReminder.reminderDescription = selectedReminder.reminderDescription
                    realmReminder.repeatMethod = RepeatMethod.once.rawValue
                    realmReminder.repeatInterval = 0
                    realmReminder.nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate()
                    
                    saveReminder(reminder: realmReminder, category: UNService.shared.selectedCategory!)
                    
                    UNService.shared.schedule(notifications: reminder)
                    
                    NotificationPersistedQueue.shared.insert(reminder)
                    let _ = NotificationPersistedQueue.shared.saveQueue()
                    
                    UNService.shared.selectedReminder = realmReminder
                }
                
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        dateLbl.text = datePicker.date.relativeFormat()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
