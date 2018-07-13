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
    
    lazy var realm = try! Realm()
    
    var reminders: Results<Reminder>?
    
    var selectedCategory: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        loadReminders()
    
    }
    
    func loadReminders(){
        reminders = selectedCategory.reminders.sorted(byKeyPath: "name")
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        let destinationVC = segue.destination as! ReminderDetailVC
//
//        if let indexPath = tableView.indexPathForSelectedRow {
//        }
//
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension CategoryRemindersVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders?[indexPath.row]
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

