//
//  NotificationService.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-03.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let dateManager = DateManager()

    private init() {}

    func scheduleHabitReminder(habitName: String, clockReminder: String, daysActive: [Bool]) {
        guard let timeComponents = dateManager.getDateComponents(from: clockReminder) else {
            print("Invalid time format")
            return
        }

        // Schedule notifications based on the daysActive array
        let daysOfWeek = [2, 3, 4, 5, 6, 7, 1]  // Assuming Monday starts at index 0 and Sunday at 6
        for (index, isActive) in daysActive.enumerated() where isActive {
            var dateComponents = DateComponents()
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.weekday = daysOfWeek[index]

            let content = UNMutableNotificationContent()
            content.title = "Habit Reminder"
            content.body = "Time to perform your \(habitName) habit!"
            content.sound = UNNotificationSound.default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "\(habitName)_\(index)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func printActiveReminders() {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                if requests.isEmpty {
                    print("No active reminders.")
                } else {
                    print("Active reminders:")
                    for request in requests {
                        let content = request.content
                        let trigger = request.trigger as? UNCalendarNotificationTrigger
                        let habitName = content.title
                        let triggerDate = trigger?.nextTriggerDate()

                        if let triggerDate = triggerDate {
                            print("Habit: \(habitName), Next Trigger Date: \(triggerDate)")
                        }
                    }
                }
            }
        }
    
    func removeNotifications(for habitName: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { $0.identifier.contains(habitName) }.map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            if !identifiersToRemove.isEmpty {
                print("Removed notifications for habit: \(habitName)")
            } else {
                print("No notifications found for habit: \(habitName)")
            }
        }
    }
    
    func removeAllNotifications() {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
}
