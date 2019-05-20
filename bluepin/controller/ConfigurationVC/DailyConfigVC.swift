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
    
    var reminderViewModel: ReminderViewModel!
    var reminderDelegate: ReminderViewModelState?

    var selectedDate: Date!
    
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
    }
    
    func configureViews(){
        let reminder = reminderViewModel.realmReminder

        self.selectedDate = reminder?.nextReminder?.date ?? Date()

        self.dateLblBtn.setTitle(self.selectedDate.relativeFormat(), for: .normal)
        self.dayIntervalStepper.value = Double(reminder?.repeatInterval ?? 1)
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
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert]) { (success) in
            guard success == true else {
                print("Can't set reminder unless permitted")
                return
            }
            
            let interval = Int(self.dayIntervalStepper.value)
            
            let groupID = self.reminderViewModel.groupID(from: self.reminderViewModel.realmReminder ?? nil)
            
            let realmReminder = self.reminderViewModel.realmReminder ?? nil
            
            self.reminderViewModel.createReminder(groupID: groupID, repeatFormat: Reminder.repeatFormat(withMethod: .daily, repeatInterval: interval),
                                                  triggerDate: self.selectedDate, repeatMethod: .daily, repeatInterval: interval) { (success) in
                                                
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
