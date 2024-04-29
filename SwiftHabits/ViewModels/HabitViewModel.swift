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
    private let dateManager = DateManager()

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
               self.updateFilteredHabits() // Ensure to filter the habits after loading
           }
       }

    func updateFilteredHabits() {
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
        let newId = UUID().uuidString  // Generate a unique ID
        let dateCreationString = dateManager.habitDayCreation()
        let newHabit = Habit(id: newId,
                             name: habitName,
                             iconName: selectedIcon,
                             frequency: frequency,
                             clockReminder: clockReminder,
                             progress: 0.0,
                             streakCount: streakCount,
                             daysActive: daysSelected,
                             dayCreated: dateCreationString)

        // Set the document in Firestore with the newId as the document ID
        let documentRef = db.collection("habits").document(newId)
        do {
            try documentRef.setData(from: newHabit) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document successfully added with ID: \(newId)")
                    DispatchQueue.main.async {
                        self.habits.append(newHabit)
                        self.updateFilteredHabits()
                        self.resetFields()
                    }
                }
            }
        } catch let serializationError {
            print("Error serializing habit: \(serializationError)")
        }
    }

    
    func saveToFirestore(habit: Habit, completion: @escaping (Bool) -> Void) {
            let collection = Firestore.firestore().collection("habits")
            do {
                let _ = try collection.addDocument(from: habit) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } catch {
                print("Error serializing habit: \(error)")
                completion(false)
            }
        }
    
    func completeHabit(to habitId: String) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            print("Habit not found")
            return
        }
        var habit = habits[index]

        // Check if the streak was already updated today
        if habit.lastStreakUpdate {
            print("Habit already done today \(habitId)")
            return
        }

        // Update habit
        habit.totalCompletions += 1
        habit.streakCount += 1
        habit.lastStreakUpdate = true
        habit.progress = 1

        // update longest streak within the same habit modification
        if habit.streakCount > habit.longestStreak {
            habit.longestStreak = habit.streakCount
        }

        habits[index] = habit  // Update the array to reflect the change

        // Update Firestore
        updateHabitInFirestore(habitId: habitId, habit: habit)
    }
    func updateHabitInFirestore(habitId: String, habit: Habit) {
        let habitRef = db.collection("habits").document(habitId)
        habitRef.updateData([
            "streakCount": habit.streakCount,
            "lastStreakUpdate": habit.lastStreakUpdate,
            "progress": habit.progress,
            "totalCompletions": habit.totalCompletions,
            "longestStreak": habit.longestStreak
        ]) { error in
            if let error = error {
                print("Error updating streak count: \(error)")
            } else {
                print("Streak count successfully updated for habit ID: \(habitId)")
            }
        }
    }

    

    func resetFields() {
        habitName = ""
        selectedIcon = ""
        frequency = "Daily"
        clockReminder = ""
        streakCount = 0
        daysSelected = [false, false, false, false, false, false, false]
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
