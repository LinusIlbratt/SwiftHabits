//
//  WeekdayPickerViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import Foundation

import Foundation

class WeekdayPickerViewModel: ObservableObject {
    @Published var selectedDayIndex = 0
    let days = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
    
    private let dateFormatter: DateFormatter
    
    // Compute the dates for the current week starting from Monday
    var weekDates: [String] {
        var dates = [String]()
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: 2 - weekday, to: today)!

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
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}


