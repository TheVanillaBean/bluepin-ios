//
//  MyReminders.swift
//  bluepin
//
//  Created by Alex on 5/11/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import PopupDialog
import InputBarAccessoryView

class MyRemindersVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)

    var reminders: Results<Reminder>?
    
    var popup: PopupDialog!
    
    var selectedReminder: Reminder!
    
    var inputBar: BPInputBar!
    
    open lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self as AutocompleteManagerDelegate
        manager.dataSource = self as AutocompleteManagerDataSource
        manager.maxSpaceCountDuringCompletion = 1
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        inputBar = BPInputBar()
        inputBar.delegate = self
        view.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.inputTextView.autocapitalizationType = .none
        inputBar.inputTextView.keyboardType = .twitter
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),.backgroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.1)])
        autocompleteManager.register(prefix: "#", with: [.font: UIFont.boldSystemFont(ofSize: size)])
        inputBar.inputPlugins = [autocompleteManager, attachmentManager]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadCategories()
        tableView.reloadData()
        UNService.shared.scheduleReminders()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    func loadCategories() {
        UNService.shared.userCategories = realm.objects(Category.self)
        reminders = realm.objects(Reminder.self).sorted(byKeyPath: "nextReminder", ascending: true)
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReminderCategoriesVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = sender as? IndexPath else { return }
        
        guard let reminder = reminders?[indexPath.row] else { return }
        
        guard let category = UNService.shared.userCategories?.filter("ANY reminders.ID = '\(reminder.ID)'").first else { return }
        
        UNService.shared.selectedCategory = category
        UNService.shared.userReminders = category.reminders.sorted(byKeyPath: "name")
        
        UNService.shared.selectedReminder = reminders?[indexPath.row]
    }
    
    func postponeReminder() {
        
        //Check if this reminder was set before and if so cancel it and remove it from the queue as it will be rescheuled and reinserted
        let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == selectedReminder.ID }
        
        if persistedReminderGroup.count > 0 {
            
            guard let category = UNService.shared.userCategories?.filter("ANY reminders.ID = '\(selectedReminder.ID)'").first else { return }
            
            guard let notification = persistedReminderGroup.first else { return }
            
            NotificationPersistedQueue.shared.remove(notification)
            
            let trigger = UNService.shared.trigger(forStartingDate: notification.date, repeatMethod: RepeatMethod.daily, repeatInterval: 1, weekdaySet: IndexSet([1, 2]))
            
            notification.repeatTrigger = trigger
            notification.date = trigger.nextTriggerDate()
            notification.notificationInfo.date = trigger.nextTriggerDate()!
            
            var _ = UNService.shared.reschedule(notification: notification)
        
            do {
                try realm.write {
                    selectedReminder.nextReminder = trigger.nextTriggerDate()
                    realm.add(selectedReminder, update: true)
                    category.reminders.append(selectedReminder)
                }
            } catch {
                print("Error saving items \(error)")
            }
            
            tableView.reloadData()
        }
        
    }
    
    func startDeletePopup() {
        let deleteWarningVC = DeleteWarningPopupVC(nibName: nil, bundle: nil)
        popup = PopupDialog(viewController: deleteWarningVC, tapGestureDismissal: true) {}
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 30
        deleteWarningVC.popup = popup
        
        deleteWarningVC.baseView.yesImageView.addTarget(self, action: #selector(self.yesBtnPressed(sender:)), for: UIControl.Event.touchUpInside)
        deleteWarningVC.baseView.noImageView.addTarget(self, action: #selector(self.noBtnPressed(sender:)), for: UIControl.Event.touchUpInside)

        present(popup, animated: true, completion: nil)
    }
    
    @objc func yesBtnPressed(sender: UIButton) {
        
        let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == selectedReminder.ID }
        
        if persistedReminderGroup.count > 0 {
            
            for notification in persistedReminderGroup {
                
                UNService.shared.cancel(notification: notification)
                NotificationPersistedQueue.shared.remove(notification)
            }
            
            do {
                try self.realm.write {
                    self.realm.delete(selectedReminder)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            
            tableView.reloadData()
            
        }
        
        popup.dismiss(animated: true, completion: nil)
    }

    @objc func noBtnPressed(sender: UIButton) {
        popup.dismiss(animated: true, completion: nil)
    }
    
    private func setStateSending() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Sending..."
        inputBar.inputTextView.isEditable = false
        inputBar.sendButton.startAnimating()
    }
    
    private func setStateReady() {
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.placeholder = "Aa"
        inputBar.inputTextView.isEditable = true
        inputBar.sendButton.stopAnimating()
    }
    
}

extension MyRemindersVC: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .border
        options.expansionStyle = .selection
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
            guard let reminder = self.reminders?[indexPath.row] else { return }
            self.selectedReminder = reminder
            self.startDeletePopup()
        }
        
        deleteAction.image = UIImage(named: "trash")?.resizeImage(CGFloat(40), opaque: false, contentMode: .scaleAspectFit)
        deleteAction.backgroundColor = #colorLiteral(red: 0.9417466521, green: 0.2130946517, blue: 0.3412085176, alpha: 1)
        deleteAction.font = UIFont(name: "Lato-Light", size: 16)

        let clockAction = SwipeAction(style: .default, title: "+1 day") { action, indexPath in
            guard let reminder = self.reminders?[indexPath.row] else { return }
            self.selectedReminder = reminder
            self.postponeReminder()
        }
        
        clockAction.image = UIImage(named: "clock-white")?.resizeImage(CGFloat(40), opaque: false, contentMode: .scaleAspectFit)
        clockAction.backgroundColor = #colorLiteral(red: 0.9721310735, green: 0.7038291693, blue: 0.2223561108, alpha: 1)
        clockAction.font = UIFont(name: "Lato-Light", size: 16)
        
        let moreAction = SwipeAction(style: .default, title: "More") { action, indexPath in
            self.performSegue(withIdentifier: "goToReminderDetailVC", sender: indexPath)
        }
        
        moreAction.image = UIImage(named: "three-dots")?.resizeImage(CGFloat(40), opaque: false, contentMode: .scaleAspectFit)
        moreAction.backgroundColor = #colorLiteral(red: 0.6061837673, green: 0.6066573262, blue: 0.6062571406, alpha: 1)
        moreAction.font = UIFont(name: "Lato-Light", size: 16)
        
        return [deleteAction, clockAction, moreAction]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = reminders?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRemindersCell", for: indexPath) as! MyRemindersCell
        cell.delegate = self
        cell.configureCell(reminder: reminder!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToReminderDetailVC", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }

}

extension MyRemindersVC: InputBarAccessoryViewDelegate {
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        inputBar.inputTextView.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        setStateSending()
        DispatchQueue.global(qos: .background).async { [weak self] in
            sleep(2)
            DispatchQueue.main.async { [weak self] in
                self?.setStateReady()
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
        print(size)
        tableView.contentInset.bottom = size.height
    }
    
}

extension MyRemindersVC: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    // MARK: - AutocompleteManagerDataSource
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        return ["InputBarAccessoryView", "iOS"].map { AutocompleteCompletion(text: $0) }
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15, keepPrefix: session.prefix == "#" )
        return cell
    }
    
    // MARK: - AutocompleteManagerDelegate
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    // MARK: - AutocompleteManagerDelegate Helper
    func setAutocompleteManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}

extension MyRemindersVC: AttachmentManagerDelegate {
    
    
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}

extension MyRemindersVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: {
            // The info dictionary may contain multiple representations of the image. You want to use the original.
            guard let selectedImage = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            
            // Set photoImageView to display the selected image.
            let handled = self.attachmentManager.handleInput(of: selectedImage)
            if !handled {
                // throw error
            }
        })
    }
}
