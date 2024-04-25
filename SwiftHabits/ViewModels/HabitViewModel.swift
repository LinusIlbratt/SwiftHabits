//
//  HabitViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI
import UserNotifications
import Firebase

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
    let db = Firestore.firestore()

    init() {
        // loadInitialData()
        filterHabitsForDay(index: Date().dayOfWeek())
        
        for habit in habits {
                    scheduleNotification(for: habit)
                }
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

    private func resetFields() {
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
    
    func filteredHabits(by dayIndex: Int) -> [Habit] {
            habits.filter { $0.daysActive[dayIndex] }
        }
    
    func filterHabitsForDay(index: Int) {
            filteredHabits = habits.filter { $0.daysActive[index] }
        }
    
    func activeHabitsForToday() -> [Habit] {
        let dayIndex = Date().dayOfWeek() 
        return habits.filter { $0.daysActive[dayIndex] }
    }
    
//    private func loadInitialData() {
//        let sampleHabits = [
//            Habit(name: "Go for a walk", iconName: "figure.walk", frequency: "Daily", clockReminder: "13:13", progress: 0.5, streakCount: 3, daysActive: [true, true, true, true, true, false, false]),
//            Habit(name: "Read a book", iconName: "book.closed", frequency: "Weekly", clockReminder: "14:00", progress: 0.3, streakCount: 2, daysActive: [false, false, false, true, false, false, true]),
//            Habit(name: "Meditation", iconName: "moon.zzz", frequency: "Daily", clockReminder: "13:03", progress: 0.7, streakCount: 3, daysActive: [true, false, true, false, true, false, true])
//        ]
//        habits.append(contentsOf: sampleHabits)
//    }
    
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
