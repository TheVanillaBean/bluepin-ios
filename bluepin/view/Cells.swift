//
//  Cells.swift
//  bluepin
//
//  Created by Alex A on 7/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

class CategoryRemindersCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(category: Category){
        self.categoryName.text = category.name
    }
    
}

class MyRemindersCell: UITableViewCell {
    
    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var weekdayLbl: UILabel!
    
    @IBOutlet weak var monthYearLbl: UIView!
    
    @IBOutlet weak var reminderNameLbl: UILabel!
    
    @IBOutlet weak var reminderDescLbl: UILabel!
    
    @IBOutlet weak var clockImageView: UIImageView!
    
    @IBOutlet weak var reminderTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(reminder: Reminder){
    }
    
}
