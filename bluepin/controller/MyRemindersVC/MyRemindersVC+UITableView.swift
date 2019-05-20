//
//  MyRemindersVC+UITableView.swift
//  bluepin
//
//  Created by Alex A on 5/19/19.
//  Copyright © 2019 Alex Alimov. All rights reserved.
//

import SwipeCellKit
import PopupDialog

extension MyRemindersVC: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func postponeReminder() {
        
        guard reminderViewModel.realmReminder != nil else {
            print("Error postponing reminder...nil")
            return
        }
        
        reminderViewModel.postponeReminder(reminder: reminderViewModel.realmReminder!) { (success) in
            guard success == true else {
                print("Error postponing reminder")
                return
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
        
        let persistedReminderGroup = NotificationPersistedQueue.shared.notificationsQueue().filter { $0.notificationInfo.identifier == reminderViewModel.realmReminder!.ID }
        
        if persistedReminderGroup.count > 0 {
            
            for notification in persistedReminderGroup {
                
                UNService.shared.cancel(notification: notification)
                NotificationPersistedQueue.shared.remove(notification)
            }
            
            do {
                try reminderViewModel.realm.write {
                    reminderViewModel.realm.delete(reminderViewModel.realmReminder!)
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
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .border
        options.expansionStyle = .selection
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
            guard let reminder = self.reminderViewModel.userReminders?[indexPath.row] else { return }
            self.reminderViewModel.realmReminder? = reminder
            self.startDeletePopup()
        }
        
        deleteAction.image = UIImage(named: "trash")?.resizeImage(CGFloat(40), opaque: false, contentMode: .scaleAspectFit)
        deleteAction.backgroundColor = #colorLiteral(red: 0.9417466521, green: 0.2130946517, blue: 0.3412085176, alpha: 1)
        deleteAction.font = UIFont(name: "Lato-Light", size: 16)
        
        let clockAction = SwipeAction(style: .default, title: "+1 day") { action, indexPath in
            guard let reminder = self.reminderViewModel.userReminders?[indexPath.row] else { return }
            self.reminderViewModel.realmReminder? = reminder
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
        return self.reminderViewModel.userReminders?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = self.reminderViewModel.userReminders?[indexPath.row]
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
