//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift

class MyRemindersVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)

    var reminders: Results<Reminder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadCategories()
        tableView.reloadData()
        print(UNService.shared.printScheduled())
    }
    
    func loadCategories() {
        UNService.shared.userCategories = realm.objects(Category.self)
        reminders = realm.objects(Reminder.self).sorted(byKeyPath: "nextReminder", ascending: true)
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReminderCategoriesVC", sender: nil)
    }

}

extension MyRemindersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRemindersCell", for: indexPath) as! MyRemindersCell
        cell.configureCell(reminder: reminder!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "goToReminderDetailVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}



