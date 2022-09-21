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
    
    func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                NotificationManager.instance.showNotification()
//                print("Fetching news for next notification!")
//                self.fetchNotificationStories()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    func fetchNotificationStories() {
        let url:URL = URL(string: "https://hacker-news.firebaseio.com/v0/newstories.json")!
        let request = APIRequest(url: url)
        request.perform { [weak self] (ids: [Int]?) -> Void in
            guard let ids = ids?.prefix(5) else { return }
            for (index, id) in ids.enumerated() {
                self?.fetchStory(withID: id) { story in
                    self?.newsTitles[index] = story?.title
                }
            }
        }
        
        var content = ""
        for title in newsTitles {
            content += title ?? "" + " | "
        }
        print("Scheduling notification!")
        showNotification(titles:content)
    }
    
    func fetchStory(withID id: Int, completion: @escaping (Item?) -> Void) {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        let request = APIRequest(url: url)
        request.perform(with: completion)
    }
    */
    
    
    func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Read stories today"
        // content.subtitle = titles // 1. NewsA, 2. NewsB, 3. NewsC, 4. NewsD, 5. NewsE
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // trigger
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // Calendar
        var dateComponents = DateComponents()
        // 24 hour clock
        dateComponents.hour = 16
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

