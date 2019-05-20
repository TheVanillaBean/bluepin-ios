//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus
import SwiftDate
import PopupDialog

class MyRemindersVC: UIViewController {
    
    fileprivate let CATEGORY_CUSTOM = "Custom"
    
    @IBOutlet weak var tableView: UITableView!
    
    var popup: PopupDialog!
    
    var inputBar: BPInputBar!
    
    var reminderViewModel: ReminderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        inputBar = BPInputBar()
        inputBar.delegate = self
        view.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.inputTextView.autocapitalizationType = .none
        inputBar.inputTextView.keyboardType = .twitter
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEventBus.unregister(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        SwiftEventBus.onMainThread(self, name:"inputbarDurationSelected") { result in
            
            if let durationRawValue: Int = result?.object as? Int {
                
                self.reminderViewModel.selectedDuration = InputBarDuration.init(rawValue: durationRawValue)
                
                if self.reminderViewModel.selectedDuration == InputBarDuration.custom {
                    self.performSegue(withIdentifier: "MyReminderToReminderConfigVC", sender: nil)
                }
                
            }
            
        }
        
        loadCategories()
        tableView.reloadData()
        UNService.shared.scheduleReminders()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    func loadCategories() {
        reminderViewModel.userCategories = reminderViewModel.realm.objects(Category.self)
        reminderViewModel.userReminders = reminderViewModel.realm.objects(Reminder.self).sorted(byKeyPath: "nextReminder", ascending: true)
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReminderCategoriesVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToReminderCategoriesVC" {
            
            if let reminderCategoryVC = segue.destination as? ReminderCategoriesVC {
                reminderCategoryVC.reminderViewModel = reminderViewModel
            }
            
        }
        
        if segue.identifier == "goToReminderDetailVC" {
            
            if let reminderDetailVC = segue.destination as? ReminderDetailVC {
                
                guard let indexPath = sender as? IndexPath else { return }
                
                guard let reminder = reminderViewModel.userReminders?[indexPath.row] else { return }
                
                guard let category = reminderViewModel.userCategories?.filter("ANY reminders.ID = '\(reminder.ID)'").first else { return }
                
                reminderViewModel.selectedCategory = category
                
                reminderViewModel.userReminders = category.reminders.sorted(byKeyPath: "name")
                
                reminderViewModel.realmReminder = reminderViewModel.userReminders?[indexPath.row]
                
                reminderDetailVC.reminderViewModel = reminderViewModel

            }
            
        }
        
        if segue.identifier == "MyReminderToReminderConfigVC" {
            
            if let reminderConfigVC = segue.destination as? ReminderConfigurationVC {
                
                reminderConfigVC.reminderViewModel = reminderViewModel
                reminderConfigVC.reminderDelegate = self
                
            }
            
        }

    }
    
    internal func customCategory() -> Category {
        let category: Category = Category()
        category.name = CATEGORY_CUSTOM
        return category
    }
    
    internal func saveReminder(reminder: Reminder, category: Category) {
        do {
            try reminderViewModel.realm.write {
                var categoryWrite = category
                
                //only add cateogry if it not already on device's realm
                if let userCateogries = reminderViewModel.userCategories?.elements {
                    if !userCateogries.contains(where: { $0.name == categoryWrite.name }) {
                        reminderViewModel.realm.add(categoryWrite)
                    } else {
                        categoryWrite = userCateogries.first(where: { $0.name == categoryWrite.name })!
                    }
                    
                    reminderViewModel.realm.add(reminder, update: true)
                    categoryWrite.reminders.append(reminder)
                }
                
            }
        } catch {
            print("Error saving items \(error)")
        }
    }
    
    internal func scheduleReminder() {
        saveReminder(reminder: reminderViewModel.realmReminder!, category: customCategory())
        UNService.shared.schedule(notifications: reminderViewModel.reminderNotif!)
        
        reminderViewModel.selectedDuration = nil
        tableView.reloadData()
    }

}

extension MyRemindersVC: ReminderViewModelState {
    func set(with reminderVM: ReminderViewModel) {
        reminderViewModel = reminderVM
    }
}

protocol ReminderViewModelState {
    func set(with reminderVM: ReminderViewModel)
}
