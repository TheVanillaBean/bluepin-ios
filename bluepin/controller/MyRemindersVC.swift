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

class MyRemindersVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var realm = try! Realm(configuration: RealmConfig.main.configuration)

    var reminders: Results<Reminder>?
    
    var popup: PopupDialog!
    
    var selectedReminder: Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadCategories()
        tableView.reloadData()
        print(NotificationPersistedQueue.shared.printQueue())

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
            
        }
        
        tableView.reloadData()
        popup.dismiss(animated: true, completion: nil)
    }

    @objc func noBtnPressed(sender: UIButton) {
        popup.dismiss(animated: true, completion: nil)
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
            if let categoryForDeletion = self.reminders?[indexPath.row]{
                print("Delete Action \(categoryForDeletion.name)")
                guard let reminder = self.reminders?[indexPath.row] else { return }
                self.selectedReminder = reminder
                self.startDeletePopup()
            }
        }
        
        deleteAction.image = UIImage(named: "trash")?.resizeImage(CGFloat(40), opaque: false, contentMode: .scaleAspectFit)
        deleteAction.backgroundColor = #colorLiteral(red: 0.9417466521, green: 0.2130946517, blue: 0.3412085176, alpha: 1)
        deleteAction.font = UIFont(name: "Lato-Light", size: 16)

        let clockAction = SwipeAction(style: .default, title: "+15 min") { action, indexPath in
            if let categoryForDeletion = self.reminders?[indexPath.row]{
                print("Clock Action \(categoryForDeletion.name)")
            }
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
