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
    var progress: Double = 0.0 // done
    var streakCount: Int = 0 // done
    var longestStreak: Int = 0 // done
    var totalCompletions: Int = 0 // done
    var totalAttempts: Int = 0 // done
    var daysActive: [Bool]
    var badges: [String] = []
    var dayCompleted: [Date] = []
    var dayCreated: String
    var isDone: Bool = false // done
    
    func isActiveDay(_ weekdayIndex: Int) -> Bool {
            return daysActive.indices.contains(weekdayIndex) && daysActive[weekdayIndex]
        }
}

