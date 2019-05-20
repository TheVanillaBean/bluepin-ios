//
//  CategoryRemindersVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryRemindersVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    
    var presetReminders: Results<Reminder>?
    
    var selectedCategory: Category!
    
    var reminderViewModel: ReminderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        categoryNameLbl.text = selectedCategory.name
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadReminders()
    }
    
    func loadReminders() {
        reminderViewModel.userReminders = reminderViewModel.selectedCategory?.reminders.sorted(byKeyPath: "name")  //User Reminders
        presetReminders = selectedCategory.reminders.sorted(byKeyPath: "name") //Preset Reminders
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let reminderDetailVC = segue.destination as? ReminderDetailVC {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                if let realmReminder = reminderViewModel.userReminders?.filter({ $0.name == self.presetReminders![indexPath.row].name }), realmReminder.count > 0{
                    reminderViewModel.realmReminder = realmReminder.last //user reminder
                } else {
                    reminderViewModel.realmReminder = presetReminders![indexPath.row] //preset reminder
                }
                
            }
            
            reminderDetailVC.reminderViewModel = self.reminderViewModel
        }

    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CategoryRemindersVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetReminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = presetReminders?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryRemindersCell", for: indexPath) as! CategoryRemindersCell
        cell.configureCell(reminder: reminder!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToReminderDetailVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

