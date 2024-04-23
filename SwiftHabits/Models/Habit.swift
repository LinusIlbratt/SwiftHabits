//
//  Habits.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import Foundation

struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var iconName: String
    var frequency: String
    var clockReminder: String
    var progress: Double = 0.0
}
