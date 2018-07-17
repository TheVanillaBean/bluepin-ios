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
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet weak var reminderNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert])
        configureViews()
    }
    
    func configureViews(){
        self.reminderDescLbl.text = selectedReminder.reminderDescription
        self.reminderDateLbl.text = selectedReminder.nextReminder?.relativeFormat() ?? Date().relativeFormat()
        self.reminderRepeatDescLbl.text = selectedReminder.repeatFormat()
        self.reminderNameLbl.text = selectedReminder.name
    }
    
    @IBAction func configureReminderBtnPressed(_ sender: Any) {
        UNService.shared.selectedReminder = selectedReminder
        performSegue(withIdentifier: "goToReminderConfigurationVC", sender: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkmarkBtnPresed(_ sender: Any) {
    }
    
    
}
