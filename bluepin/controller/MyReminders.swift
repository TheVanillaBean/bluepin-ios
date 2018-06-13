//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

class MyReminders: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNService.shared.requestAuthorization(forOptions: [.badge, .sound, .alert])
        
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        
        UNService.shared.cancelAll()
        
        var components = DateComponents()
        components.second = 0
        
        let notification = BluepinNotification(body: "This is a test notification")
        notification.title = "This is a test title"
        notification.badge = 5
        

        let retrievedNotification = UNService.shared.notification(withIdentifier: notification.identifier)

        print("\(retrievedNotification?.title)")
        
    }
    

}

