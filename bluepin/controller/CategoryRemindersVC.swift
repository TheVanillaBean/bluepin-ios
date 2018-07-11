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
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        loadCategories()
    
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ReminderDetailVC
        
        if let indexPath = tableView.indexPathForSelectedRow {
        }
        
    }

}

extension CategoryRemindersVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryRemindersCell", for: indexPath) as! CategoryRemindersCell
        cell.configureCell(category: category!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToReminderDetailVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}

