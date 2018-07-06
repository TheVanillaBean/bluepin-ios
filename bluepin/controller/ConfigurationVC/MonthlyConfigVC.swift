//
//  MonthlyConfigVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftDate

class MonthlyConfigVC: UIViewController {

    @IBOutlet weak var dayIntervalStepper: GMStepper!
    
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
        
        let popup = PopupDialog(viewController: datePickerVC, gestureDismissal: false) {
            print("Date Trigger canceled")
        }
        
        let buttonOne = DefaultButton(title: "Set Time", height: 60) {
            let dateString = datePickerVC.datePicker.date.inDefaultRegion().toFormat("EEEE, MMM d 'at' h:mm a", locale: Locales.english)
            print("Date Trigger \(dateString)")
        }
        
        let buttonTwo = CancelButton(title: "Cancel", height: 60) {
            print("Date Trigger canceled")
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        
        present(popup, animated: true, completion: nil)
    }
    
    @IBAction func setBtn(_ sender: Any) {
        print("Stepper \(dayIntervalStepper.value)")
    }
}
