//
//  DatePickerPopupVC.swift
//  bluepin
//
//  Created by Alex A on 7/4/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog

class DatePickerPopupVC: UIViewController {

    public weak var popup: PopupDialog?
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func loadView() {
        view = datePicker
    }
    
}
