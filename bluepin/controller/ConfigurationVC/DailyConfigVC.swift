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
    
    @IBAction func startDateBtnPressed(_ sender: Any) {
        let datePickerVC = DatePickerPopupVC(nibName: nil, bundle: nil)
        datePickerVC.datePicker.setDate(self.selectedDate, animated: false)

        let popup = PopupDialog(viewController: datePickerVC, tapGestureDismissal: true) {}
        
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
        
        guard let reminder = UNService.shared.reminder(withTitle: selectedReminder.name, body:  Reminder.repeatFormat(withMethod: .daily, repeatInterval: interval), startingDate: selectedDate, repeatMethod: .daily, repeatInterval: interval, groupIdentifer: groupID)  else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let realmReminder = Reminder()
        realmReminder.ID = (reminder.last?.notificationInfo.identifier)!
        realmReminder.name = selectedReminder.name
        realmReminder.reminderDescription = selectedReminder.reminderDescription
        realmReminder.repeatMethod = RepeatMethod.daily.rawValue
        realmReminder.repeatInterval = interval
        realmReminder.nextReminder = reminder.first?.repeatTrigger?.nextTriggerDate()
        
        if persistedReminderGroup.count > 0 {
            
            for notification in persistedReminderGroup {
                
                UNService.shared.cancel(notification: notification)
                NotificationPersistedQueue.shared.remove(notification)
            }
            
        }
        
        saveReminder(reminder: realmReminder, category: UNService.shared.selectedCategory!)
        
        UNService.shared.schedule(notifications: reminder) 

        UNService.shared.selectedReminder = realmReminder
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
