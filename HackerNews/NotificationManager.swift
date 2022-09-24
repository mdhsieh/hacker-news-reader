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
    
    var newsTitles: [String?] = Array(repeating: nil, count: 5)
    
    // Schedule daily notifications once on app startup
    @AppStorage("shouldScheduleNotifications") var shouldScheduleNotifications = true
    
    func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                NotificationManager.instance.scheduleRepeatedDailyNotification()
                print("Scheduled daily notification")
                NotificationManager.instance.shouldScheduleNotifications = false
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func scheduleRepeatedDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Read stories today"
        content.subtitle = "Tap to read now"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // trigger
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // Calendar
        var dateComponents = DateComponents()
        // 24 hour clock
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

