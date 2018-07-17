//
//  ReminderConfigurationVC.swift
//  bluepin
//
//  Created by Alex A on 7/1/18.
//  Copyright © 2018 Alex Alimov. All rights reserved.
//

import UIKit
import Pageboy

class ReminderConfigurationVC: PageboyViewController {
    
    let pageControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        let onceVC = storyboard.instantiateViewController(withIdentifier: "OnceConfigVC") as! OnceConfigVC
        let dailyVC = storyboard.instantiateViewController(withIdentifier: "DailyConfigVC") as! DailyConfigVC
        let weeklyVC = storyboard.instantiateViewController(withIdentifier: "WeeklyConfigVC") as! WeeklyConfigVC
        let monthlyVC = storyboard.instantiateViewController(withIdentifier: "MonthlyConfigVC") as! MonthlyConfigVC
        
        viewControllers.append(onceVC)
        viewControllers.append(dailyVC)
        viewControllers.append(weeklyVC)
        viewControllers.append(monthlyVC)
        
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let selectedReminder = UNService.shared.selectedReminder {
            switch selectedReminder.repeatMethod {
            case RepeatMethod.once.rawValue:
                scrollToPage(.at(index: 0), animated: true)
            case RepeatMethod.daily.rawValue:
                scrollToPage(.at(index: 1), animated: true)
            case RepeatMethod.weekly.rawValue:
                scrollToPage(.at(index: 2), animated: true)
            case RepeatMethod.monthly.rawValue:
                scrollToPage(.at(index: 3), animated: true)
            default:
                scrollToPage(.at(index: 0), animated: true)
            }
        }
    }

    @objc func nextPage(_ sender: UIBarButtonItem) {
        scrollToPage(.next, animated: true)
    }
    
    @objc func previousPage(_ sender: UIBarButtonItem) {
        scrollToPage(.previous, animated: true)
    }

}

extension ReminderConfigurationVC: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .first
    }
}

extension ReminderConfigurationVC: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollTo position: CGPoint,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        

    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
       
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didReloadWith currentViewController: UIViewController,
                               currentPageIndex: PageboyViewController.PageIndex) {
    }
}

