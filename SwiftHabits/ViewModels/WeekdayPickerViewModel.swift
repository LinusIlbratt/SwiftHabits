//
//  WeekdayPickerViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import Foundation

import Foundation

class WeekdayPickerViewModel: ObservableObject {
    @Published var selectedDayIndex = 1
    let days = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
    
    private let dateFormatter: DateFormatter
    
    // Compute the dates for the current week starting from Monday
    var weekDates: [String] {
        var dates = [String]()
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // Sunday = 1, Monday = 2, ...
        let startOfWeek = calendar.date(byAdding: .day, value: 2 - weekday, to: today)! // Adjust to make Monday as the start of the week

        for i in 0..<7 {
            if let dateToAdd = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(dateFormatter.string(from: dateToAdd))
            }
        }
        return dates
    }
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d" // Only day of the month
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent use
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}


