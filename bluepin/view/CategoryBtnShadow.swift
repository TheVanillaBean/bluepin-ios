//
//  CategoryBtnShadow.swift
//  bluepin
//
//  Created by Alex on 5/16/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit

@IBDesignable
class CategoryBtnShadow: UIButton {

    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView(){
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowColor = #colorLiteral(red: 0.1341417134, green: 0.1341417134, blue: 0.1341417134, alpha: 1)
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

}
