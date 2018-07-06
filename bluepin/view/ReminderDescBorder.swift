//
//  ReminderDescBorder.swift
//  bluepin
//
//  Created by Alex A on 7/3/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

@IBDesignable
class ReminderDescBorder: UIView {

    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView(){
        self.layer.borderColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 6
    }
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

}
