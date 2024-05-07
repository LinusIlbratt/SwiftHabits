//
//  CalendarViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-02.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date
    private var dateManager = DateManager()

    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
    }

    var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "sv_SE")  // Ensure it's set to Swedish locale
        return formatter
    }
    
    var monthOnlyFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"  // Format for the month name only
            formatter.locale = Locale(identifier: "en_SV")  // Ensure it's using English or adjust as necessary
            return formatter
        }

    func moveToNextMonth() {
        currentMonth = dateManager.changeMonth(for: currentMonth, by: 1)
    }

    func moveToPreviousMonth() {
        currentMonth = dateManager.changeMonth(for: currentMonth, by: -1)
    }

    func monthMetadata() -> MonthMetadata? {
        return dateManager.monthMetadata(for: currentMonth)
    }


    var weekdays: [String] {
        var days = dateManager.calendar.shortWeekdaySymbols  // Adjusted to the correct locale setting
        let sunday = days.removeFirst()  // Move Sunday to the end if needed
        days.append(sunday)
        return days
    }

    func firstDayOfWeekday() -> Int? {  // Now returns an optional Int
        guard let metadata = monthMetadata() else {
            return nil  // Return nil if metadata is not available
        }

        var firstDayWeekday = dateManager.calendar.component(.weekday, from: metadata.firstDay)
        firstDayWeekday = (firstDayWeekday + 5) % 7  // Adjust so Monday is 0
        return firstDayWeekday
    }

}



