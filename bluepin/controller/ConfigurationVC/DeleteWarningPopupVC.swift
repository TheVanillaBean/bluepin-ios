//
//  DeleteWarningPopupVC.swift
//  bluepin
//
//  Created by Alex A on 3/9/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import UIKit
import PopupDialog

class DeleteWarningPopupVC: UIViewController {

    public weak var popup: PopupDialog?

    let deleteWarning = DeleteWarningPopup()

    var baseView: DeleteWarningPopup {
        return view as! DeleteWarningPopup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func loadView() {
        view = deleteWarning
    }
    
    func yesBtnPressed(sender: UIButton) {
        print("Yes Btn Pressed")
    }

}
