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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        categoryNameLbl.text = selectedCategory.name
        
        loadReminders()
    
    }
    
    func loadReminders() {
        UNService.shared.userReminders = UNService.shared.selectedCategory?.reminders.sorted(byKeyPath: "name")  //User Reminders
        presetReminders = selectedCategory.reminders.sorted(byKeyPath: "name") //Preset Reminders
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            if (UNService.shared.userReminders?.contains(where: { $0.name == presetReminders![indexPath.row].name }))! {
                UNService.shared.selectedReminder = UNService.shared.userReminders?[indexPath.row] //user reminder
            } else {
                UNService.shared.selectedReminder = presetReminders![indexPath.row] //preset reminder
            }
            
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

