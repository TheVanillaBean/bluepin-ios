//
//  OnceConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import SwiftDate

class OnceConfigVC: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    

    @IBAction func onceBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 0), animated: true)
    }
    
    @IBAction func dailyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 1), animated: true)
    }
    
    @IBAction func weeklyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 2), animated: true)
    }
    
    @IBAction func monthlyBtnPressed(_ sender: Any) {
        parentPageboy?.scrollToPage(.at(index: 3), animated: true)
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        let dateString = datePicker.date.inDefaultRegion().toFormat("EEEE, MMM d 'at' h:mm a", locale: Locales.english)
        let reminder = UNService.shared.reminder(withTitle: "Reminder", body: "Rem", startingDate: datePicker.date)
        
        print("Date Trigger \(dateString)")
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
