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
import FirebaseAuth

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var filteredHabits: [Habit] = []
    @Published var habitName: String = ""
    @Published var iconName: String = ""
    @Published var selectedIcon: String = ""
    @Published var frequency: String = ""
    @Published var clockReminder: String = ""
    @Published var streakCount: Int = 0
    @Published var dayCompleted: [Date] = []
    @Published var daysSelected: [Bool] = Array(repeating: false, count: 7)
    @Published var selectAllDays: Bool = false  // default all days to false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let dateManager = DateManager()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var habitService = HabitService()
    
    init() {
        loadHabits()
    }
    
    deinit {
        listener?.remove()
    }
    
    
    func loadHabits() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: User is not logged in")
                return
            }
            
            habitService.loadHabits(for: userId) { [weak self] (habits, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting habits: \(error)")
                    return
                }
                guard let habits = habits else { return }

                DispatchQueue.main.async {
                    self.habits = habits
                    self.checkForDayChange()
                    self.updateFilteredHabits()
                    self.calculateMissedDaysForAllHabits()
                    NotificationService.shared.printActiveReminders()
                }
            }
        }
    
    func addHabit() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: User is not logged in")
                return
            }

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

            // call habitservice to add a new habit to firestore
            habitService.addHabit(habit: newHabit, userId: userId) { success in
                DispatchQueue.main.async {
                    if success {
                        self.habits.append(newHabit)
                        self.updateFilteredHabits()
                        self.resetFields()
                        NotificationService.shared.scheduleHabitReminder(habitName: newHabit.name, clockReminder: newHabit.clockReminder, daysActive: newHabit.daysActive)
                        print("Document successfully added with ID: \(newId)")
                    } else {
                        print("Failed to add the document.")
                    }
                }
            }
        }
    
    func calculateMissedDaysForAllHabits() {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())

        for index in habits.indices {
            guard let lastCompletionDate = habits[index].dayCompleted.last else { continue }
            let lastDate = calendar.startOfDay(for: lastCompletionDate)

            var currentDateIter = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            var missedDays = 0

            while currentDateIter > lastDate {
                let weekdayIndex = calendar.component(.weekday, from: currentDateIter) - 1  // Adjust to 0-based index, Monday = 0

                if habits[index].isActiveDay(weekdayIndex) {
                    missedDays += 1
                }

                currentDateIter = calendar.date(byAdding: .day, value: -1, to: currentDateIter)!
            }

            if missedDays > 0 {
                habits[index].streakCount = 0
                updateStreakCount(habit: habits[index])
                habits[index].totalAttempts += missedDays
                updateTotalAttempts(habit: habits[index])
            }
        }
    }
    
    
    
    func updateStreakCount(habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid else {
                    print("Error: User is not logged in")
                    return
                }
                habitService.updateStreakCount(for: habit, userId: userId) { error in
                    if let error = error {
                        print("Error updating streak count for habit \(habit.name): \(error)")
                    } else {
                        print("Streak count successfully reset for habit \(habit.name)")
                    }
                }
    }
    
    
    func updateTotalAttempts(habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }
        habitService.updateTotalAttempts(for: habit, userId: userId) { error in
            if let error = error {
                print("Error updating total attempts for habit \(habit.name): \(error)")
            } else {
                print("Total attempts successfully updated for habit \(habit.name)")
            }
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
    
    
    func saveToFirestore(habit: Habit, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            completion(false)
            return
        }
        
        let userHabitPath = Firestore.firestore().collection("users").document(userId).collection("habits")
        do {
            let _ = try userHabitPath.addDocument(from: habit) { error in
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
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            print("Habit not found")
            return
        }
        var habit = habits[index]

        // Check if the habit was already marked as done today
        if habit.isDone {
            print("Habit already done today \(habitId)")
            return
        }

        // Update habit
        habit.totalCompletions += 1
        habit.totalAttempts += 1
        habit.streakCount += 1
        habit.isDone = true
        habit.progress = 1
        habit.dayCompleted.append(Date())  // Append the new date

        // Update the longest streak within the same habit modification
        if habit.streakCount > habit.longestStreak {
            habit.longestStreak = habit.streakCount
        }

        habits[index] = habit  // Update the array to reflect the change
        
        habitService.updateCompletedHabit(userId: userId, habitId: habitId, habit: habit) { success in
            if success {
                print("Habit successfully updated for habit ID: \(habitId)")
            } else {
                print("Failed to update habit in Firestore.")
            }
        }
    }
    
    
    func storeLastKnownDay() {
        let today = Calendar.current.startOfDay(for: Date()) // Normalize to midnight
        UserDefaults.standard.set(today, forKey: "lastKnownDay")
    }
    
    func getLastKnownDay() -> Date? {
        return UserDefaults.standard.object(forKey: "lastKnownDay") as? Date
    }
    
    func checkForDayChange() {
        let dateManager = DateManager() // Assuming DateManager is accessible here
        let currentDay = Calendar.current.startOfDay(for: Date())
        print("Current Day: \(dateManager.formattedDateTime(for: currentDay))")
        
        if let lastKnownDay = getLastKnownDay() {
            print("Last Known Day: \(dateManager.formattedDateTime(for: lastKnownDay))")
            
            if lastKnownDay != currentDay {
                print("resetting")
                resetIsDoneAndProgressForAllHabits()
                updateTotalAttempts()
                storeLastKnownDay()
            }
        } else {
            print("No last known day stored, setting current day.")
            storeLastKnownDay()
        }
    }
    
    
    
    func resetIsDoneAndProgressForAllHabits() {
        print("Number of habits to reset: \(habits.count)")
        for index in habits.indices {
            var habit = habits[index]
            print("Resetting habit with ID: \(habit.id ?? "ID not found")")
            habit.isDone = false
            habit.progress = 0
            habits[index] = habit
            resetHabitProgress(habit: habit)
        }
    }
    
    
    
    func resetHabitProgress(habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        habitService.resetHabitProgress(userId: userId, habit: habit) { success in
            if success {
                print("Habit progress reset successfully for habit ID: \(habit.id ?? "unknown ID")")
            } else {
                print("Failed to reset habit progress.")
            }
        }
    }
    
    
    func updateTotalAttempts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }
        
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        let todayIndex = (currentWeekday + 5) % 7
        
        for var habit in habits {
            guard let habitId = habit.id else {
                print("Habit ID is nil")
                continue
            }
            
            if habit.daysActive.indices.contains(todayIndex) && habit.daysActive[todayIndex] {
                habit.totalAttempts += 1
                habitService.updateTotalAttemptsForHabit(userId: userId, habitId: habitId, attempts: habit.totalAttempts) { success in
                    if success {
                        print("Updated total attempts for \(habit.name)")
                    } else {
                        print("Failed to update total attempts for \(habit.name)")
                    }
                }
            }
        }
    }

    
    
    func calculateMissedActiveDays(for habit: Habit, until currentDate: Date) -> Int {
        guard let lastCompletionDate = habit.dayCompleted.last else {
            print("No completion date available for habit \(habit.name)")
            return 0
        }
        
        let calendar = Calendar.current
        let daysPassed = calendar.dateComponents([.day], from: lastCompletionDate, to: currentDate).day ?? 0
        
        // Check if daysPassed is positive before creating a range
        guard daysPassed > 0 else {
            return 0
        }
        
        var missedDaysCount = 0
        
        // Iterate over the days between the last completion date and the current date
        for dayOffset in 1...daysPassed {
            // Calculate the date for each day
            guard let missedDate = calendar.date(byAdding: .day, value: -dayOffset, to: currentDate) else {
                continue
            }
            
            let weekdayIndex = calendar.component(.weekday, from: missedDate) - 1 // Adjusted to match your weekday indexing
            
            // Check if the habit is active on the missed day
            if habit.daysActive.indices.contains(weekdayIndex) && habit.daysActive[weekdayIndex] {
                missedDaysCount += 1
            }
        }
        
        return missedDaysCount
    }
        
    
    func resetFields() {
        habitName = ""
        selectedIcon = ""
        frequency = "Daily"
        clockReminder = ""
        streakCount = 0
        daysSelected = [false, false, false, false, false, false, false]
    }
    
    func validateAndAddHabit() -> Bool {
        guard !habitName.isEmpty else {
            alertMessage = "Please enter a habit name."
            showAlert = true
            return false
        }
        guard daysSelected.contains(true) else {
            alertMessage = "Please select at least one day."
            showAlert = true
            return false
        }

        addHabit()  // Call the function to add the habit if validation passes
        return true
    }
    
}

extension HabitViewModel {
    
    func removeHabit(at offsets: IndexSet) {
            let habitsToRemove = offsets.map { filteredHabits[$0] }
            filteredHabits.remove(atOffsets: offsets)
            
            for habit in habitsToRemove {
                if let habitId = habit.id {
                    habitService.removeHabitFromDatabase(userId: Auth.auth().currentUser?.uid, habit: habit, habitId: habitId) { success in
                        if success {
                            print("Habit successfully removed from database")
                            self.loadHabits()
                        } else {
                            print("Error removing habit")
                        }
                    }
                }
            }
        }   
    
}

