//
//  HabitViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var habitName: String = ""
    @Published var iconName: String = ""
    @Published var selectedIcon: String = ""
    @Published var frequency: String = "Daily"
    @Published var clockReminder: String = ""
    @Published var streakCount: Int = 0
    @Published var daysSelected: [Bool] = [false, false, false, false, false, false, false]  // Default all days to false

    init() {
        loadInitialData()
    }
    
    func addHabit() {
        let newHabit = Habit(
            name: habitName,
            iconName: selectedIcon,
            frequency: frequency,
            clockReminder: clockReminder,
            progress: 0.0,  // Initial progress is usually 0
            streakCount: streakCount,
            daysActive: daysSelected
        )
        habits.append(newHabit)
        resetFields()
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
    
    func filteredHabits(by dayIndex: Int) -> [Habit] {
            habits.filter { $0.daysActive[dayIndex] }
        }
    
    func activeHabitsForToday() -> [Habit] {
        let dayIndex = Date().dayOfWeek() 
        return habits.filter { $0.daysActive[dayIndex] }
    }
    
    private func loadInitialData() {
        let sampleHabits = [
            Habit(name: "Go for a walk", iconName: "figure.walk", frequency: "Daily", clockReminder: "08:00 AM", progress: 0.5, streakCount: 3, daysActive: [true, true, true, true, true, false, false]),
            Habit(name: "Read a book", iconName: "book.closed", frequency: "Weekly", clockReminder: "21:00 PM", progress: 0.3, streakCount: 2, daysActive: [false, false, false, true, false, false, true]),
            Habit(name: "Meditation", iconName: "moon.zzz", frequency: "Daily", clockReminder: "07:00 AM", progress: 0.7, streakCount: 3, daysActive: [true, false, true, false, true, false, true])
        ]
        habits.append(contentsOf: sampleHabits)
    }

}
