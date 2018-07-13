//
//  DailyConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftDate

class DailyConfigVC: UIViewController {
    
    @IBOutlet weak var dateLblBtn: UIButton!
    
    @IBOutlet weak var dayIntervalStepper: GMStepper!
    
    var selectedDate: Date!
    
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
    
    @IBAction func startDateBtnPressed(_ sender: Any) {
        
        let datePickerVC = DatePickerPopupVC(nibName: nil, bundle: nil)
        
        let popup = PopupDialog(viewController: datePickerVC, gestureDismissal: true) {}
        
        let buttonOne = DefaultButton(title: "Set Time", height: 60) {
            self.selectedDate = datePickerVC.datePicker.date
            self.dateLblBtn.titleLabel?.text = datePickerVC.datePicker.date.relativeFormat()
        }
        
        let buttonTwo = CancelButton(title: "Cancel", height: 60) {}
        
        popup.addButtons([buttonOne, buttonTwo])
        
        present(popup, animated: true, completion: nil)
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        
        let interval = Int(dayIntervalStepper.value)
        
        if let reminder = UNService.shared.reminder(withTitle: "Reminder", body: "Body", startingDate: selectedDate, repeatMethod: .daily, repeatInterval: interval){
            UNService.shared.schedule(notifications: reminder)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
