//
//  MyRemindersVC+InputBar.swift
//  bluepin
//
//  Created by Alex A on 5/19/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import InputBarAccessoryView
import SwiftDate

extension MyRemindersVC: InputBarAccessoryViewDelegate {
    
    internal func setStateAdding() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Adding Reminder..."
        inputBar.inputTextView.isEditable = false
        inputBar.sendButton.startAnimating()
    }
    
    internal func setStateReady() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Aa"
        inputBar.inputTextView.isEditable = true
        inputBar.sendButton.stopAnimating()
    }
    
    internal func calculateTriggerDate(duration: InputBarDuration) -> Date? {
        if duration == InputBarDuration.ten_minutes {
            return Date() + 5.seconds
        } else if duration == InputBarDuration.one_hours {
            return Date() + 30.seconds
        } else if duration == InputBarDuration.six_hours {
            return Date() + 2.minutes
        } else if duration == InputBarDuration.one_days {
            return Date() + 1.days
        }
        return nil
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        inputBar.inputTextView.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard let selectedDuration = self.reminderViewModel.selectedDuration else {
            //select a duration first - make a banner popup
            print("Select Duration First...")
            return
        }
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert]) { (success) in
            guard success == true else {
                print("Can't set reminder unless permitted")
                return
            }
            
            self.setStateAdding()
            
            if selectedDuration == InputBarDuration.custom {
                print("custom")
                guard self.reminderViewModel.reminderNotif != nil, self.reminderViewModel.realmReminder != nil else{
                    return
                }
                
                self.reminderViewModel.updateReminder(reminder: self.reminderViewModel.reminderNotif, title: text) { (success) in
                    
                    guard success == true, self.reminderViewModel.realmReminder != nil, self.reminderViewModel.reminderNotif != nil else {
                        print("Error creating reminder")
                        return
                    }
                    
                    self.scheduleReminder()
                }
            } else {
                guard let date = self.calculateTriggerDate(duration: selectedDuration) else {
                    //show error banner | there was an error
                    print("Error calculating date")
                    return
                }
                
                self.reminderViewModel.createReminder(name: text,
                                                 repeatFormat: Reminder.repeatFormat(withMethod: .once, repeatInterval: 0),
                                                 triggerDate: date,
                                                 repeatMethod: .once,
                                                 repeatInterval: 1) { (success) in
                                                    
                                                    guard success == true, self.reminderViewModel.realmReminder != nil, self.reminderViewModel.reminderNotif != nil else {
                        print("Error creating reminder")
                        return
                    }
                    
                    self.scheduleReminder()
                                                    
                }
            }
            
            self.setStateReady()
        }
        
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
        print(size)
        tableView.contentInset.bottom = size.height
    }
    
}
