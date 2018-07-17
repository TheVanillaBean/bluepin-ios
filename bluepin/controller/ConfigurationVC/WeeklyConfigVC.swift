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

        let popup = PopupDialog(viewController: datePickerVC, gestureDismissal: true) {}
        
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
        
        weekBtn.setImage(UIImage(named: weekBtnImageNames[weekBtn.tag]), for: .normal)
        
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        if let reminder = UNService.shared.reminder(withTitle: "Reminder", body: "Body", startingDate: selectedDate, repeatMethod: .weekly, repeatInterval: 1, weekdaySet: weeklyIndexSet){
            
            if let selectedReminder = UNService.shared.selectedReminder {
                
                if UNService.shared.alreadySetReminder! {
                    UNService.shared.selectedReminder?.repeatMethod = RepeatMethod.weekly.rawValue
                    UNService.shared.selectedReminder?.repeatInterval = 1
                    UNService.shared.selectedReminder?.weekdaySet = Reminder.toRealmList(withWeekdaySet: weeklyIndexSet)
                    UNService.shared.selectedReminder?.nextReminder = reminder.last?.repeatTrigger?.nextTriggerDate()
                    
                    saveReminder(reminder: UNService.shared.selectedReminder!, category: UNService.shared.selectedCategory!)
                } else {
                    let realmReminder = Reminder()
                    realmReminder.name = selectedReminder.name
                    realmReminder.reminderDescription = selectedReminder.reminderDescription
                    realmReminder.repeatMethod = RepeatMethod.weekly.rawValue
                    realmReminder.repeatInterval = 1
                    realmReminder.weekdaySet = Reminder.toRealmList(withWeekdaySet: weeklyIndexSet)
                    realmReminder.nextReminder = reminder.last?.repeatTrigger?.nextTriggerDate()
                    
                    saveReminder(reminder: realmReminder, category: UNService.shared.selectedCategory!)
                }
                
                UNService.shared.schedule(notifications: reminder)
            }

            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
