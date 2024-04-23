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

    let days = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
    
    // Computed property returning a list of this week's dates using dateManager.
    var weekDates: [String] {
        dateManager.weekDates(startingFrom: Date())
    }
    
    
    init() {
        selectedDayIndex = dateManager.getDayIndex(for: Date()) // Sets selectedDayIndex to current day using dateManager
        observeTimeChanges()
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
        let dayNumber = calendar.component(.weekday, from: self)
        return (dayNumber + 5) % 7  // justera beroende på din dagordning, Calendar: söndag är standard 1
    }
}


