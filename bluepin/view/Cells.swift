//
//  Cells.swift
//  bluepin
//
//  Created by Alex A on 7/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import SwiftDate
import SwipeCellKit

class CategoryRemindersCell: UITableViewCell {
    
    @IBOutlet weak var reminderName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(reminder: Reminder){
        self.reminderName.text = reminder.name
    }
    
}

class MyRemindersCell: SwipeTableViewCell{
    
    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var weekdayLbl: UILabel!
    
    @IBOutlet weak var monthYearLbl: UILabel!
    
    @IBOutlet weak var reminderNameLbl: UILabel!
    
    @IBOutlet weak var reminderDescLbl: UILabel!
    
    @IBOutlet weak var clockImageView: UIImageView!
    
    @IBOutlet weak var reminderTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(reminder: Reminder){
        self.reminderNameLbl.text = reminder.name
        self.reminderDescLbl.text = reminder.parentCategory.first?.name
        
        self.dayLbl.text = reminder.nextReminder?.inDefaultRegion().toFormat("d", locale: Locales.english)
        self.weekdayLbl.text = reminder.nextReminder?.inDefaultRegion().toFormat("EEEE", locale: Locales.english)
        self.monthYearLbl.text = reminder.nextReminder?.inDefaultRegion().toFormat("MMM yyyy", locale: Locales.english)
        
        self.reminderTimeLbl.text = reminder.nextReminder?.inDefaultRegion().toFormat("h:mm a", locale: Locales.english).lowercased()
        
        if (reminder.nextReminder?.compare(.isToday))! || (reminder.nextReminder?.compare(.isTomorrow))!{
            self.clockImageView.image = UIImage(named: "clock-red")
            self.reminderTimeLbl.textColor = #colorLiteral(red: 1, green: 0, blue: 0.1450980392, alpha: 1)
        }
        
    }
    
    
}
