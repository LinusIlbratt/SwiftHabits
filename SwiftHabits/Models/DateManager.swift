//
//  DateManager.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

import Foundation

struct MonthMetadata {
    var firstDay: Date
    var numberOfDays: Int
}

class DateManager {
     let calendar: Calendar
     var forcedDayIndex: Int?
     let dateFormatter: DateFormatter
     let dayDateFormatter: DateFormatter
     let dateTimeFormatter: DateFormatter

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "sv_SE")
        calendar.timeZone = TimeZone.current
        self.calendar = calendar

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = Locale(identifier: "sv_SE")
        dateFormatter.timeZone = TimeZone.current

        dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "MM/dd/yyyy"
        dayDateFormatter.locale = Locale(identifier: "sv_SE")
        dayDateFormatter.timeZone = TimeZone.current

        dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateTimeFormatter.locale = Locale(identifier: "sv_SE")
        dateTimeFormatter.timeZone = TimeZone.current
    }

    func monthMetadata(for baseDate: Date) -> MonthMetadata {
            let components = calendar.dateComponents([.year, .month], from: baseDate)
            let startOfMonth = calendar.date(from: components)!
            let numberOfDays = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
            return MonthMetadata(firstDay: startOfMonth, numberOfDays: numberOfDays)
        }

    func changeMonth(for date: Date, by months: Int) -> Date {
            return calendar.date(byAdding: .month, value: months, to: date) ?? date
        }

    func weekDates(startingFrom startDate: Date) -> [String] {
        let weekday = calendar.component(.weekday, from: startDate)
        guard let startOfWeek = calendar.date(byAdding: .day, value: -((weekday + 5) % 7), to: startDate) else {
            return []
        }
        return (0..<7).map { offset in
            let dateToAdd = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            return dateFormatter.string(from: dateToAdd)
        }
    }

    func getDayIndex(for date: Date) -> Int {
        if let forcedIndex = forcedDayIndex {
            return forcedIndex
        }
        let weekday = calendar.component(.weekday, from: date)
        return (weekday + 5) % 7
    }
    
    func setDayIndex(index: Int) {
        forcedDayIndex = index
    }
    
    func habitDayCreation() -> String {
        return dayDateFormatter.string(from: Date())
    }

    func formattedDateTime(for date: Date) -> String {
        return dateTimeFormatter.string(from: date)
    }
}


