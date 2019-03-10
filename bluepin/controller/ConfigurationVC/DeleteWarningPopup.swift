//
//  DeleteWarningVC.swift
//  bluepin
//
//  Created by Alex A on 3/9/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import UIKit

class DeleteWarningPopup: UIView {
    
    let yesImageView: UIButton = {
        let button:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "are-u-sure-checkmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let noImageView: UIButton = {
        let button:UIButton = UIButton(frame: CGRect(x: 110, y: 0, width: 60, height: 60))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "are-u-sure-cancel"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let label: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedText = NSMutableAttributedString(string: "Are you sure?", attributes: [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 20.0)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1755868296, green: 0.4319446227, blue: 0.736805279, alpha: 1)])
        
        textview.attributedText = attributedText
        
        textview.textAlignment = .center
        textview.isEditable = false
        textview.isScrollEnabled = false
        return textview
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupLayout()
    }
    
    
    func setupLayout() {
        
        let stackView = UIStackView(arrangedSubviews: [yesImageView, noImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 75
        
        addSubview(label)
        addSubview(stackView)
        
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        NSLayoutConstraint.activate([
            yesImageView.heightAnchor.constraint(equalToConstant: 60),
            yesImageView.widthAnchor.constraint(equalToConstant: 60),
            noImageView.heightAnchor.constraint(equalToConstant: 60),
            noImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.topAnchor, constant: -12),
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
        
    }
    
}
