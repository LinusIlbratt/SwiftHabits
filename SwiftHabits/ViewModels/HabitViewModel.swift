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
    
    func addHabit(iconName: String) {
        let newHabit = Habit(name: habitName, iconName: iconName)
        habits.append(newHabit)
        // Reset the fields after adding the habit
        habitName = ""
    }
}
