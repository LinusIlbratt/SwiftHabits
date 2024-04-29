//
//  DateManager.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

class DateManager {
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter
    private let dayDateFormatter: DateFormatter

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d" // Only the day of the month
        dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "MM/dd/yyyy"
    }

    func weekDates(startingFrom startDate: Date) -> [String] {
        let weekday = calendar.component(.weekday, from: startDate)
        // Calculate the start of the week (assuming Monday as the first day of the week)
        guard let startOfWeek = calendar.date(byAdding: .day, value: -((weekday + 5) % 7), to: startDate) else {
            return []
        }

        return (0..<7).compactMap { offset in
            let dateToAdd = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            return dateFormatter.string(from: dateToAdd)
        }
    }

    func getDayIndex(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date) // Sunday = 1, Monday = 2, ...
        // Adjust for array starting with Monday as 0
        return (weekday + 5) % 7
    }
    
    func habitDayCreation() -> String {
        let dateCreatedString = dayDateFormatter.string(from: Date())
        return dateCreatedString
    }
}

