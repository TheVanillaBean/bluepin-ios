//
//  ReminderCategoriesVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift

class ReminderCategoriesVC: UIViewController {

    lazy var presetRealm = try! Realm(configuration: RealmConfig.preset.configuration)
    
    var categories: Results<Category>?
    
    var reminderViewModel: ReminderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    func loadCategories() {
        categories = presetRealm.objects(Category.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoryRemindersVC = segue.destination as? CategoryRemindersVC {
            reminderViewModel.selectedCategory = reminderViewModel.userCategories?[sender as! Int] //from main user realm
            categoryRemindersVC.selectedCategory = categories![sender as! Int] //from preset bundled realm
            categoryRemindersVC.reminderViewModel = self.reminderViewModel
        }
    }
 
    @IBAction func categoryBtnPressed(_ categoryBtn: UIButton) {
        performSegue(withIdentifier: "goToCategoryRemindersVC", sender: categoryBtn.tag)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
