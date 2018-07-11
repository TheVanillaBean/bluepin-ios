//
//  ReminderCategoriesVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

class ReminderCategoriesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
 
    @IBAction func categoryBtnPressed(_ categoryBtn: UIButton) {
        
        performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
        
    }
    
}
