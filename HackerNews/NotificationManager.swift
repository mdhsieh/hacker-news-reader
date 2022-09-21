//
//  NotificationManager.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/21/22.
//

import SwiftUI
// Send a daily notification with the top n news
import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                NotificationManager.instance.showNotification()
                print("Scheduling notification!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Top news today"
        content.subtitle = "1. NewsA, 2. NewsB, 3. NewsC, 4. NewsD, 5. NewsE"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // trigger
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // Calendar
        var dateComponents = DateComponents()
        // 24 hour clock
        dateComponents.hour = 15
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

