//
//  Habits.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import Foundation

struct Habit: Identifiable {
    let id = UUID() // Ensures each habit is unique, helpful for Lists
    var name: String
}
