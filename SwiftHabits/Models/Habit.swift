//
//  Habits.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import Foundation
import FirebaseFirestoreSwift

struct Habit: Identifiable, Codable {
    var id: String?
    var name: String
    var iconName: String
    var frequency: String
    var clockReminder: String
    var progress: Double = 0.0
    var streakCount: Int = 0
    var longestStreak: Int = 0
    var totalCompletions: Int = 0
    var totalAttempts: Int = 0
    var daysActive: [Bool]
    var badges: [String] = []
    var dayCompleted: [Date] = []
    var dayCreated: String
    var lastStreakUpdate: Bool = false
}

