//
//  ReminderDetailVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

class ReminderDetailVC: UIViewController {

    var selectedReminder: Reminder!

    @IBOutlet weak var reminderDescLbl: UILabel!
    @IBOutlet weak var reminderDateLbl: UILabel!
    @IBOutlet weak var reminderRepeatDescLbl: UILabel!
//    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet weak var reminderNameLbl: UILabel!
    
    var reminderViewModel: ReminderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        selectedReminder = reminderViewModel.realmReminder
        configureViews()
    }
    
    func configureViews(){
        self.reminderDescLbl.text = selectedReminder.reminderDescription
        self.reminderDateLbl.text = selectedReminder.nextReminder?.relativeFormat() ?? Date().relativeFormat()
        self.reminderRepeatDescLbl.text = selectedReminder.repeatFormat()
        self.reminderNameLbl.text = selectedReminder.name
    }
    
    @IBAction func configureReminderBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReminderConfigurationVC", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
//        UNService.shared.userReminders = UNService.shared.selectedCategory?.reminders.sorted(byKeyPath: "name")  //User Reminders
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "goToReminderConfigurationVC" {
            
            if let reminderConfigVC = segue.destination as? ReminderConfigurationVC {
                reminderConfigVC.reminderViewModel = reminderViewModel
                reminderConfigVC.reminderDelegate = nil
            }
            
        }
        
    }
    
    
//    @IBAction func checkmarkBtnPresed(_ sender: Any) {
//    }
//
    
}
