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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    func loadCategories() {
        categories = presetRealm.objects(Category.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CategoryRemindersVC
        UNService.shared.selectedCategory  = UNService.shared.userCategories?[sender as! Int] //user
        destinationVC.selectedCategory = categories![sender as! Int] //preset
    }
 
    @IBAction func categoryBtnPressed(_ categoryBtn: UIButton) {
        performSegue(withIdentifier: "goToCategoryRemindersVC", sender: categoryBtn.tag)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
