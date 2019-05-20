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
    
    var reminderViewModel: ReminderViewModel!
    var reminderDelegate: ReminderViewModelState?
    
    var weekBtnImageNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var weeklyIndexSet = IndexSet()
    var selectedDate: Date!

    override func viewDidLoad() {
        let reminder = reminderViewModel.realmReminder

        configureWeekdaySet(withReminder: reminder)
        configureViews(withReminder: reminder)
    }
    
    func configureViews(withReminder reminder: Reminder?) {
        self.selectedDate = reminder?.nextReminder?.date ?? Date()
        self.dateLblBtn.setTitle(self.selectedDate.relativeFormat(), for: .normal)
    }
    
    func configureWeekdaySet(withReminder reminder: Reminder?){
        self.weeklyIndexSet = reminder?.toIndexSet() ?? [0, 1, 2, 3, 4, 5, 6]
        for index in self.weeklyIndexSet {
            weekBtnImageNames[index].append("-orange")
            weekdayBtns[index].setImage(UIImage(named: weekBtnImageNames[index]), for: .normal)
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
        
        weekBtn.setImage(UIImage(named: weekBtnImageNames[weekBtn.tag]), for: .normal)
        
        if weeklyIndexSet.count == 0 {
            weeklyIndexSet.insert(integersIn: 0...6)
            weekBtnImageNames = ["Sun-orange", "Mon-orange", "Tue-orange", "Wed-orange", "Thu-orange", "Fri-orange", "Sat-orange"]
            for index in weeklyIndexSet {
                weekdayBtns[index].setImage(UIImage(named: weekBtnImageNames[index]), for: .normal)
            }
        }
        
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert]) { (success) in
            guard success == true else {
                print("Can't set reminder unless permitted")
                return
            }
            
            let groupID = self.reminderViewModel.groupID(from: self.reminderViewModel.realmReminder ?? nil)
            
            let realmReminder = self.reminderViewModel.realmReminder ?? nil
            
            self.reminderViewModel.createReminder(groupID: groupID, repeatFormat: Reminder.repeatFormat(withMethod: .weekly, repeatInterval: 1),
                                                  triggerDate: self.selectedDate, repeatMethod: .weekly, repeatInterval: 1,
                                                  weekdaySet: self.weeklyIndexSet) { (success) in
                                                
                guard success == true else {
                    print("Did Not Successfully Create a Reminder...")
                    self.dismiss(animated: true, completion: nil)
                    return
                }

                if let duration = self.reminderViewModel.selectedDuration, duration == InputBarDuration.custom {
                    print("Custom Duration...")
                    self.reminderDelegate?.set(with: self.reminderViewModel)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    
                    self.reminderViewModel.updateReminder(reminder: self.reminderViewModel?.reminderNotif, title: realmReminder?.name, desc:
                        realmReminder?.reminderDescription, completionHandler: { (success) in
                            
                            guard success == true else {
                                print("Did Not Successfully Update a Reminder")
                                self.dismiss(animated: true, completion: nil)
                                return
                            }
                            
                            self.reminderViewModel.deletePreviousNotifications()
                            
                            self.reminderViewModel.saveReminder(reminder: self.reminderViewModel.realmReminder!, category: self.reminderViewModel.selectedCategory!)
                            
                            UNService.shared.schedule(notifications: self.reminderViewModel.reminderNotif!)
                            
                            self.dismiss(animated: true, completion: nil)
                    })
                    
                }
            }
        }
        
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
