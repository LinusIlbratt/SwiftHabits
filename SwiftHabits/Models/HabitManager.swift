//
//  HabitManager.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

class HabitManager: ObservableObject {
    @Published var habits: [Habit] = [] // This will hold all habits

    func addHabit(name: String) {
        let newHabit = Habit(name: name)
        habits.append(newHabit) // Adds a new habit
    }
}
