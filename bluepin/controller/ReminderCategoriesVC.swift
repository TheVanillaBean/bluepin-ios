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

    lazy var realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CategoryRemindersVC
        destinationVC.selectedCategory = sender as! Category
    }
 
    @IBAction func categoryBtnPressed(_ categoryBtn: UIButton) {
        performSegue(withIdentifier: "goToCategoryRemindersVC", sender: categories?[categoryBtn.tag])
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
