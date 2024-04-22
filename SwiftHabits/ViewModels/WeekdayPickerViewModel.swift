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
    
    // computed property returing a list of this weeks dates using dateManager.
    var weekDates: [String] {
        dateManager.weekDates(startingFrom: Date())
    }
    
    
    init() {
        selectedDayIndex = dateManager.getDayIndex(for: Date()) // sets selectedDayIndex to current day using dateManager
        observeTimeChanges()
    }
    
    // subscribes to system notifications for significant time changes, such as the start of a new day
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
    
    // cancels all active subscriptions on deinitialization.
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
}

// computed property to get the start of the current day.
// returns the date set to midnight according to the current calendar and timezone.
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}


