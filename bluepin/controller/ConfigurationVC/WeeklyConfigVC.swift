//
//  WeeklyConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftDate
import RealmSwift

class WeeklyConfigVC: UIViewController {

    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var dateLblBtn: UIButton!
    
    @IBOutlet var weekdayBtns: [UIButton]!
    
    var weekBtnImageNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var weeklyIndexSet = IndexSet()
    var selectedDate: Date!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedReminder = UNService.shared.selectedReminder {
            self.selectedDate = selectedReminder.nextReminder?.date ?? Date()
            configureWeekdaySet(withReminder: selectedReminder)
            configureViews(wihReminder: selectedReminder)
        }
    }
    
    func configureViews(wihReminder reminder: Reminder){
        self.dateLblBtn.setTitle(self.selectedDate.relativeFormat(), for: .normal)
    }
    
    func configureWeekdaySet(withReminder reminder: Reminder){
        self.weeklyIndexSet = reminder.toIndexSet()
        for index in self.weeklyIndexSet {
            weekBtnImageNames[index].append("-orange")
            weekdayBtns[index].setImage(UIImage(named: weekBtnImageNames[index]), for: .normal)
        }
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
    
    @IBAction func startDateBtn(_ sender: Any) {
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
    
    @IBAction func dayOfWeekBtnPressed(_ weekBtn: UIButton) {
        
        let weeklybtnImageName = weekBtnImageNames[weekBtn.tag]
        
        if weeklybtnImageName.contains("orange") {
            weekBtnImageNames[weekBtn.tag] = weeklybtnImageName.replacingOccurrences(of: "-orange", with: "")
            weeklyIndexSet.remove(weekBtn.tag)
        }else{
            weekBtnImageNames[weekBtn.tag].append("-orange")
            weeklyIndexSet.insert(weekBtn.tag)
        }
        print("tag \(weekBtn.tag)")
        weekBtn.setImage(UIImage(named: weekBtnImageNames[weekBtn.tag]), for: .normal)
        
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
        
        guard let reminder = UNService.shared.reminder(withTitle: selectedReminder.name, body:  Reminder.repeatFormat(withMethod: .weekly, repeatInterval: 1), startingDate: selectedDate, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: weeklyIndexSet, groupIdentifer: groupID)  else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let realmReminder = Reminder()
        realmReminder.ID = (reminder.last?.notificationInfo.identifier)!
        realmReminder.name = selectedReminder.name
        realmReminder.reminderDescription = selectedReminder.reminderDescription
        realmReminder.repeatMethod = RepeatMethod.weekly.rawValue
        realmReminder.repeatInterval = 1
        realmReminder.weekdaySet = Reminder.toRealmList(withWeekdaySet: weeklyIndexSet)
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
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
