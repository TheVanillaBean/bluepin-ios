//
//  DailyConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftDate
import RealmSwift

class DailyConfigVC: UIViewController {
    
    @IBOutlet weak var dateLblBtn: UIButton!
    @IBOutlet weak var dayIntervalStepper: GMStepper!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)
    
    var selectedDate: Date!
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedReminder = UNService.shared.selectedReminder {
            self.selectedDate = selectedReminder.nextReminder?.date ?? Date()
            configureViews(wihReminder: selectedReminder)
        }
    }
    
    func configureViews(wihReminder reminder: Reminder){
        self.dateLblBtn.setTitle(self.selectedDate.relativeFormat(), for: .normal)
        self.dayIntervalStepper.value = Double(reminder.repeatInterval)
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
    
    @IBAction func startDateBtnPressed(_ sender: Any) {
        let datePickerVC = DatePickerPopupVC(nibName: nil, bundle: nil)
        datePickerVC.datePicker.setDate(self.selectedDate, animated: false)

        let popup = PopupDialog(viewController: datePickerVC, gestureDismissal: true) {}
        
        let buttonOne = DefaultButton(title: "Set Time", height: 60) {
            self.selectedDate = datePickerVC.datePicker.date
            self.dateLblBtn.setTitle(self.selectedDate.relativeFormat(), for: .normal)
        }
        
        let buttonTwo = CancelButton(title: "Cancel", height: 60) {}
        
        popup.addButtons([buttonOne, buttonTwo])
        
        present(popup, animated: true, completion: nil)
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        
        let interval = Int(dayIntervalStepper.value)
        
        if let reminder = UNService.shared.reminder(withTitle: (UNService.shared.selectedReminder?.name)!, body:  Reminder.repeatFormat(withMethod: .daily, repeatInterval: interval), startingDate: selectedDate, repeatMethod: .daily, repeatInterval: interval) {
            
            if let selectedReminder = UNService.shared.selectedReminder {
                
                let reminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == selectedReminder.ID }
                
                if reminderGroup.count > 0 {

                    do {
                        try realm.write {
                            
                            for reminder in reminderGroup {
                                
                                UNService.shared.cancel(withIdentifier: reminder.identifier)
                                NotificationPersistedQueue.shared.remove(reminder)
                            }
                            
                            UNService.shared.schedule(notifications: reminder)
                            
                            NotificationPersistedQueue.shared.insert(reminder)
                            let _ = NotificationPersistedQueue.shared.saveQueue()
                            
                            UNService.shared.selectedReminder?.ID = (reminder.last?.notificationInfo.identifier)!
                            UNService.shared.selectedReminder?.repeatMethod = RepeatMethod.daily.rawValue
                            UNService.shared.selectedReminder?.repeatInterval = interval
                            UNService.shared.selectedReminder?.nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate()
                        }
                    } catch {
                        print("Error saving items \(error)")
                    }
                    
                } else {
                    
                    let realmReminder = Reminder()
                    realmReminder.ID = (reminder.last?.notificationInfo.identifier)!
                    realmReminder.name = selectedReminder.name
                    realmReminder.reminderDescription = selectedReminder.reminderDescription
                    realmReminder.repeatMethod = RepeatMethod.daily.rawValue
                    realmReminder.repeatInterval = interval
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
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
