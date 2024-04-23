//
//  HabitViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var habitName: String = ""  // Default empty string to start with
    @Published var iconName: String = ""   // Default icon name
    @Published var selectedIcon: String = ""   // Default icon name
    @Published var frequency: String = "Daily" // Default frequency value
    @Published var clockReminder: String = ""
    @Published var streakCount: Int = 0

    
    init() {
            loadInitialData()
        }

    func addHabit() {
        let newHabit = Habit(name: habitName, iconName: selectedIcon, frequency: frequency, clockReminder: clockReminder, streakCount: streakCount)
        habits.append(newHabit)
        resetFields()
    }

    private func resetFields() {
        habitName = ""  // Reset the fields after adding the habit
        iconName = ""  // Ensure this is reset if needed elsewhere or handled differently
        selectedIcon = ""  // Reset selected icon
        frequency = "Daily" // Reset frequency to default
        clockReminder = ""
    }
    
    private func loadInitialData() {
            
            let sampleHabits = [
                Habit(name: "Go for a walk", iconName: "figure.walk", frequency: "Daily", clockReminder: "08:00 AM", progress: 0.5, streakCount: 3),
                Habit(name: "Read a book", iconName: "book.closed", frequency: "Weekly", clockReminder: "21:00 PM", progress: 0.3, streakCount: 2),
                Habit(name: "Meditation", iconName: "moon.zzz", frequency: "Daily", clockReminder: "07:00 AM", progress: 0.7, streakCount: 3)
            ]
            habits.append(contentsOf: sampleHabits)
        }
}
