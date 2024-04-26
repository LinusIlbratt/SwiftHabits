//
//  HabitViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseFirestoreSwift

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var filteredHabits: [Habit] = []
    @Published var habitName: String = ""
    @Published var iconName: String = ""
    @Published var selectedIcon: String = ""
    @Published var frequency: String = "Daily"
    @Published var clockReminder: String = ""
    @Published var streakCount: Int = 0
    @Published var daysSelected: [Bool] = [false, false, false, false, false, false, false]  // default all days to false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        loadHabits()
    }
    
    deinit {
        listener?.remove()
    }
    
    func loadHabits() {
            db.collection("habits").getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents")
                    return
                }
                self.habits = documents.compactMap { document -> Habit? in
                    try? document.data(as: Habit.self)
                }
                self.filterHabitsForToday()
            }
        }

        func filterHabitsForToday() {
            let todayIndex = self.currentDayIndex()
            self.filteredHabits = self.habits.filter { habit in
                habit.daysActive[todayIndex]
            }
        }

        func currentDayIndex() -> Int {
            let currentWeekday = Calendar.current.component(.weekday, from: Date()) // Sunday = 1, Monday = 2, etc.
            return (currentWeekday + 5) % 7 // Adjusting index to match your array (Monday = 0)
        }

    
    func addHabit() {
        let newHabit = Habit(name: habitName,
                             iconName: selectedIcon,
                             frequency: frequency,
                             clockReminder: clockReminder,
                             progress: 0.0,
                             streakCount: streakCount,
                             daysActive: daysSelected)
        saveToFirestore(habit: newHabit)
    }

    func resetFields() {
        habitName = ""
        iconName = ""
        selectedIcon = ""
        frequency = "Daily"
        clockReminder = ""
        streakCount = 0
        daysSelected = [false, false, false, false, false, false, false]
    }
    
    private func saveToFirestore(habit: Habit) {
           do {
               try db.collection("habits").addDocument(from: habit)
           } catch let error {
               print("Error writing habit to Firestore: \(error)")
           }
       }

    
    func scheduleNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(habit.name)"
        content.body = "Time to engage in your habit!"
        content.sound = UNNotificationSound.default

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        // fetch current day
        let today = Date()

        // fetch time from habit.clockReminder
        guard let time = dateFormatter.date(from: habit.clockReminder) else {
            print("Error: Invalid time format for reminder: \(habit.clockReminder)")
            return
        }

        // create a new date with current day and time from habit.clockReminder
        var components = Calendar.current.dateComponents([.year, .month, .day], from: today)
        components.hour = Calendar.current.component(.hour, from: time)
        components.minute = Calendar.current.component(.minute, from: time)

        guard let date = Calendar.current.date(from: components) else {
            print("Error: Unable to create date for reminder: \(habit.clockReminder)")
            return
        }

        let timeInterval = date.timeIntervalSinceNow
        if timeInterval <= 0 {
            print("Error: Reminder time has already passed for \(habit.name) at \(habit.clockReminder)")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        // Using the Firestore ID directly if available, otherwise a random UUID
        let requestID = habit.id ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for habit: \(habit.name) at \(habit.clockReminder)")
            }
        }
    }

}
