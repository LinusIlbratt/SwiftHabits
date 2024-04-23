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
    
    func addHabit() {
        let newHabit = Habit(name: habitName)
        habits.append(newHabit)
        habitName = "" // reset name after add
    }
}
