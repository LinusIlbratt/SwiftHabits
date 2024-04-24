//
//  WeekdayPickerViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import Foundation
import Combine
import UIKit

class WeekdayPickerViewModel: ObservableObject {
    @Published var selectedDayIndex = 0
    private var dateManager = DateManager()
    private var cancellables = Set<AnyCancellable>()
    @Published var weekDates: [Date] = []

    let days = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
    
    // computed property to generate formatted date strings for the current week
    var datesForWeek: [String] {
        let today = Date()
        let weekDates = dateManager.weekDates(startingFrom: today)
        return weekDates
    }
    
    
    init() {
        updateWeekDates()
        selectedDayIndex = dateManager.getDayIndex(for: Date()) // Sets selectedDayIndex to current day using dateManager
        observeTimeChanges()
    }
    
    func isTodaySelected() -> Bool {
        let today = Date()
        let calendar = Calendar.current
        let selectedDayIndex = selectedDayIndex
        
        let adjustedDayIndex = (selectedDayIndex + 1 + 7) % 7
        
        let selectedDate = weekDates[adjustedDayIndex]
        
        return calendar.isDate(today, inSameDayAs: selectedDate)
    }
    
    func updateWeekDates() {
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            weekDates = (0..<7).map { i in
                calendar.date(byAdding: .day, value: i - (weekday - 1), to: today)!
            }
        }
    
    // Subscribes to system notifications for significant time changes, such as the start of a new day
    private func observeTimeChanges() {
        NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateSelectedDayIndex()
            }
            .store(in: &cancellables)
    }
    
    private func updateSelectedDayIndex() {
        let newDayIndex = dateManager.getDayIndex(for: Date())
        DispatchQueue.main.async {
            self.selectedDayIndex = newDayIndex
        }
    }
    
    // Cancels all active subscriptions on deinitialization.
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
}

// Computed property to get the start of the current day.
// Returns the date set to midnight according to the current calendar and timezone.
extension Date {
    func dayOfWeek() -> Int {
        let calendar = Calendar.current
        var dayNumber = calendar.component(.weekday, from: self) - 2
        if dayNumber < 0 {
            dayNumber += 7
        }
        return dayNumber
    }
}

