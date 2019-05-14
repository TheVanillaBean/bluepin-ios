//
//  SlackInputBar.swift
//  Example
//
//  Created by Nathan Tannar on 2018-06-06.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import SwiftEventBus

class BPInputBar: InputBarAccessoryView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func toggleSelectedButton(_ items: [InputBarButtonItem], i: Int) {
        items[i].onSelected { (item) in
            items.forEach { $0.tintColor = .lightGray }
            item.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
        }
        print("count: \(i)")
    }
    
    func configure() {
        let items = [
            makeButton(named: "ic_camera").onSelected {
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                SwiftEventBus.post("inputbarDurationSelected", sender: InputBarDuration.ten_minutes)
            },
            makeButton(named: "ic_at").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "@" as AnyObject) }
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                SwiftEventBus.post("inputbarDurationSelected", sender: InputBarDuration.one_hours)
            },
            makeButton(named: "ic_hashtag").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "#" as AnyObject) }
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                SwiftEventBus.post("inputbarDurationSelected", sender: InputBarDuration.six_hours)
            },
            makeButton(named: "ic_camera").onSelected {
                    $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                    SwiftEventBus.post("inputbarDurationSelected", sender: InputBarDuration.one_days)
            },
            .flexibleSpace,
            makeButton(named: "ic_at").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "@" as AnyObject) }
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                SwiftEventBus.post("inputbarDurationSelected", sender: InputBarDuration.custom)
            }
        ]
        items.forEach { $0.tintColor = .lightGray }
        
        //used for toggling which button is tinted. When one button is selected, all others should have tints set back to default
        for i in 0...items.count - 1 {
            items[i].onSelected { (item) in
                items.forEach { $0.tintColor = .lightGray }
                item.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                SwiftEventBus.post("inputbarDurationSelected", sender: i)
            }
        }
        
        sendButton
            .configure {
                $0.layer.cornerRadius = 8
                $0.layer.borderWidth = 1.5
                $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                $0.setTitleColor(.white, for: .normal)
                $0.setTitleColor(.white, for: .highlighted)
                $0.setSize(CGSize(width: 52, height: 20), animated: false)
                $0.title = "Add"
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .white
                }.onEnabled {
                    $0.backgroundColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        
        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        let maxSizeItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate)
                $0.tintColor = .darkGray
                $0.setSize(CGSize(width: 20, height: 20), animated: false)
            }.onSelected {
                let oldValue = $0.inputBarAccessoryView?.shouldForceTextViewMaxHeight ?? false
                $0.image = oldValue ? UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icons8-collapse")?.withRenderingMode(.alwaysTemplate)
                self.setShouldForceMaxTextViewHeight(to: !oldValue, animated: true)
        }
        
        
        rightStackView.alignment = .top
        setStackViewItems([maxSizeItem, sendButton], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 82, animated: false)
        rightStackView.spacing = 8
        
        // Finally set the items
        topStackView.axis = .horizontal
        topStackView.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        topStackView.isLayoutMarginsRelativeArrangement = true
        setStackViewItems(items, forStack: .top, animated: false)
        
    }
    
    override func calculateMaxTextViewHeight() -> CGFloat {
        if traitCollection.verticalSizeClass == .regular {
            return (UIScreen.main.bounds.height / 4).rounded(.down)
        }
        return (UIScreen.main.bounds.height / 5).rounded(.down)
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(20)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }
    }
    
}

extension BPInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: {
            // The info dictionary may contain multiple representations of the image. You want to use the original.
            guard let pickedImage = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            self.inputPlugins.forEach { _ = $0.handleInput(of: pickedImage) }
        })
    }
}
