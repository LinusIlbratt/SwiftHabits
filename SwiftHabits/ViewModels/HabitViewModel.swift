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

    func addHabit() {
        let newHabit = Habit(name: habitName, iconName: selectedIcon, frequency: frequency, clockReminder: clockReminder)
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
}
