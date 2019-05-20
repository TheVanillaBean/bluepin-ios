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
    
    var reminderViewModel: ReminderViewModel!
    var reminderDelegate: ReminderViewModelState?
    
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
    }
    
    func configureViews(){
        let reminder = reminderViewModel.realmReminder
        
        self.datePicker.setDate(reminder?.nextReminder?.date ?? Date(), animated: true)
        self.dateLbl.text = reminder?.nextReminder?.date.relativeFormat() ?? Date().relativeFormat()
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
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert]) { (success) in
            guard success == true else {
                print("Can't set reminder unless permitted")
                return
            }
            
            let groupID = self.reminderViewModel.groupID(from: self.reminderViewModel.realmReminder ?? nil)
            
            let realmReminder = self.reminderViewModel.realmReminder ?? nil
            
            self.reminderViewModel.createReminder(groupID: groupID, repeatFormat: Reminder.repeatFormat(withMethod: .once, repeatInterval: 0),
                                             triggerDate: self.datePicker.date, repeatMethod: .once, repeatInterval: 0) { (success) in
                                                
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
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        dateLbl.text = datePicker.date.relativeFormat()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

