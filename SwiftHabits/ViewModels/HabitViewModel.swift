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
    @Published var frequency: String = "Daily"
    @Published var clockReminder: String = ""
    @Published var streakCount: Int = 0
    @Published var dayCompleted: [Date] = []
    @Published var daysSelected: [Bool] = [false, false, false, false, false, false, false]  // default all days to false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let dateManager = DateManager()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
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
        
        let userHabitsPath = db.collection("users").document(userId).collection("habits")
        
        userHabitsPath.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            self.habits = documents.compactMap { document -> Habit? in
                try? document.data(as: Habit.self)
            }
            
            self.checkForDayChange()
            self.updateFilteredHabits() // Ensure to filter the habits after loading
            self.calculateMissedDaysForAllHabits()
        }
    }
    
    func calculateMissedDaysForAllHabits() {
        let currentDate = Date()
        for index in habits.indices {
            guard let lastCompletionDate = habits[index].dayCompleted.last else { continue }
            
            let missedDays = calculateMissedActiveDays(for: habits[index], until: currentDate)
            print("Missed active days for habit \(habits[index].name): \(missedDays)")
            
            if missedDays > 0 {
                // Reset the streak count if there are missed days
                habits[index].streakCount = 0
                updateStreakCountInFirestore(habit: habits[index])
            }
            
            // Update total attempts
            habits[index].totalAttempts += missedDays
            
            // Update Firestore for total attempts
            updateTotalAttemptsForHabit(habit: habits[index])
        }
    }
    
    
    
    func updateStreakCountInFirestore(habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid, let habitId = habit.id else { return }
        
        let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
        habitRef.updateData([
            "streakCount": habit.streakCount
        ]) { error in
            if let error = error {
                print("Error updating streak count for habit \(habit.name): \(error)")
            } else {
                print("Streak count successfully reset for habit \(habit.name)")
            }
        }
    }
    
    
    func updateTotalAttemptsForHabit(habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }
        guard let habitId = habit.id else {
            print("Error: Habit ID is nil")
            return
        }
        let userHabitRef = Firestore.firestore().collection("users").document(userId).collection("habits").document(habitId)
        userHabitRef.updateData([
            "totalAttempts": habit.totalAttempts
        ]) { error in
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
        
        // Set the document in Firestore under the user's 'habits' sub-collection
        let userHabitPath = db.collection("users").document(userId).collection("habits").document(newId)
        do {
            try userHabitPath.setData(from: newHabit) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document successfully added with ID: \(newId)")
                    DispatchQueue.main.async {
                        self.habits.append(newHabit)
                        self.updateFilteredHabits()
                        self.resetFields()
                    }
                    
                    // Schedule a notification for the new habit
                    NotificationService.shared.scheduleHabitReminder(habitName: newHabit.name, clockReminder: newHabit.clockReminder, daysActive: newHabit.daysActive)
                }
            }
        } catch let serializationError {
            print("Error serializing habit: \(serializationError)")
        }
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
        habit.streakCount += 1
        habit.isDone = true
        habit.progress = 1
        habit.dayCompleted.append(Date())  // Append the new date
        
        // Update the longest streak within the same habit modification
        if habit.streakCount > habit.longestStreak {
            habit.longestStreak = habit.streakCount
        }
        
        habits[index] = habit  // Update the array to reflect the change
        
        // Update Firestore
        updateCompletedHabitToFirestore(userId: userId, habitId: habitId, habit: habit)
    }
    
    func updateCompletedHabitToFirestore(userId: String, habitId: String, habit: Habit) {
        let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
        habitRef.updateData([
            "streakCount": habit.streakCount,
            "progress": habit.progress,
            "totalCompletions": habit.totalCompletions,
            "longestStreak": habit.longestStreak,
            "dayCompleted": habit.dayCompleted.map { Timestamp(date: $0) },  // Ensure correct date conversion
            "isDone": habit.isDone
        ]) { error in
            if let error = error {
                print("Error updating habit: \(error)")
            } else {
                print("Habit successfully updated for habit ID: \(habitId)")
            }
        }
    }
    
    
    func storeLastKnownDay() {
        let today = Calendar.current.startOfDay(for: Date()) // Normalize to midnight
        UserDefaults.standard.set(today, forKey: "lastKnownDay")
    }
    
    func getLastKnownDay() -> Date? {
        return UserDefaults.standard.object(forKey: "lastKnownDay") as? Date
        // let calendar = Calendar.current
        // return calendar.date(from: DateComponents(year: 2024, month: 4, day: 28))
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
        print("this is running")
        print("Number of habits to reset: \(habits.count)")
        for index in habits.indices {
            var habit = habits[index]
            print("Resetting habit with ID: \(habit.id ?? "ID not found")")
            habit.isDone = false
            habit.progress = 0
            habits[index] = habit
            updateHabitResetToFirestore(habit)
        }
    }
    
    
    
    func updateHabitResetToFirestore(_ habit: Habit) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }
        guard let habitId = habit.id else {
            print("Error: Habit ID is nil")
            return
        }
        let userHabitRef = Firestore.firestore().collection("users").document(userId).collection("habits").document(habitId)
        userHabitRef.updateData([
            "isDone": habit.isDone,
            "progress": habit.progress
        ]) { error in
            if let error = error {
                print("Error updating habit: \(error)")
            } else {
                print("Habit successfully updated with reset values for habit ID: \(habitId)")
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
            
            // check if today is an active day for the habit
            if habit.daysActive.indices.contains(todayIndex) && habit.daysActive[todayIndex] {
                // increase total attempts only if it's an active day
                habit.totalAttempts += 1
                // update to Firestore using the user-specific path
                
                let userHabitRef = Firestore.firestore().collection("users").document(userId).collection("habits").document(habitId)
                userHabitRef.updateData([
                    "totalAttempts": habit.totalAttempts
                ]) { error in
                    if let error = error {
                        print("Error updating total attempts for Habit ID: \(habitId): \(error)")
                    } else {
                        print("Total attempts successfully updated for Habit ID: \(habitId)")
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
    
}
