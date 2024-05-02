//
//  SummaryView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-01.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @StateObject private var habitViewModel = HabitViewModel()

    var body: some View {
        VStack {
            CalendarView(viewModel: calendarViewModel)
            
            Spacer()
            
            HabitSummaryView(viewModelHabit: habitViewModel, viewModelCalendar: calendarViewModel)
        }
    }
}

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: viewModel.moveToPreviousMonth) {
                    Image(systemName: "arrow.left")
                }

                Text("\(viewModel.currentMonth, formatter: viewModel.monthYearFormatter)")
                    .font(.headline)

                Button(action: viewModel.moveToNextMonth) {
                    Image(systemName: "arrow.right")
                }
            }
            
            MonthView(viewModel: viewModel)
        }
    }
}

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        let metadata = viewModel.monthMetadata()
        let firstDayWeekday = viewModel.firstDayOfWeekday()
        let weekdays = viewModel.weekdays

        return VStack {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }

            // day grid
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0..<42, id: \.self) { index in
                    if index < firstDayWeekday || index >= firstDayWeekday + metadata.numberOfDays {
                        Text("")
                            .frame(width: 40, height: 40)
                    } else {
                        Text("\((index - firstDayWeekday) + 1)")
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct HabitSummaryView: View {
    @ObservedObject var viewModelHabit: HabitViewModel
    @ObservedObject var viewModelCalendar: CalendarViewModel  // Pass this from SummaryView
    @State private var selectedSegment = 0

    var body: some View {
        VStack {
            Picker("Habits", selection: $selectedSegment) {
                ForEach(0..<viewModelHabit.habits.count, id: \.self) { index in
                    Text(viewModelHabit.habits[index].name).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if !viewModelHabit.habits.isEmpty {
                HStack {
                    DaysDoneInMonthView(viewModel: viewModelCalendar, dayCompleted: viewModelHabit.habits[selectedSegment].dayCompleted)
                    TotalCompletionsView(totalCompletions: viewModelHabit.habits[selectedSegment].totalCompletions)
                }
                HStack {
                    StreakCountView(streakCount: viewModelHabit.habits[selectedSegment].streakCount)
                    LongestStreakView(longestStreak: viewModelHabit.habits[selectedSegment].longestStreak)
                }
            }
        }
    }
}


struct StreakCountView: View {
    var streakCount: Int

    var body: some View {
        VStack(spacing: 4) { // Reduced spacing between the texts
            Text("Current streak:")
                .foregroundColor(.white)
                .font(.subheadline) // Optional styling for the label
            
            Text("\(streakCount)")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Apply frame to contain the entire VStack
        .background(Color.blue) // Background color for the entire card
        .cornerRadius(10) // Rounded corners for the card
        .padding() // Padding around the card
    }
}

struct LongestStreakView: View {
    var longestStreak: Int
    
    var body: some View {
        VStack(spacing: 4) {
        Text("Best streak:")
            .font(.subheadline)
            .foregroundColor(.white)
            
        Text("\(longestStreak)")
            .font(.headline)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Apply frame to contain the entire VStack
        .background(Color.blue) // Background color for the entire card
        .cornerRadius(10) // Rounded corners for the card
        .padding() // Padding around the card
    }
        
}

struct TotalCompletionsView: View {
    var totalCompletions: Int
    
    var body: some View {
        VStack(spacing: 4) {
        Text("Total days done:")
            .font(.subheadline)
            .foregroundColor(.white)
            
        Text("\(totalCompletions)")
            .font(.headline)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Apply frame to contain the entire VStack
        .background(Color.blue) // Background color for the entire card
        .cornerRadius(10) // Rounded corners for the card
        .padding() // Padding around the card
    }
    
}

struct DaysDoneInMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var dayCompleted: [Date]
    
    var body: some View {
        // Compute the count of dates in the current month
        let daysCompletedInMonth = dayCompleted.filter { date in
            let monthYearFormatter = DateFormatter()
            monthYearFormatter.dateFormat = "yyyy MM"
            return monthYearFormatter.string(from: date) == monthYearFormatter.string(from: viewModel.currentMonth)
        }.count

        // Display the count and the month name
        VStack {
            Text("\(daysCompletedInMonth)")
                .font(.largeTitle)
            Text("days done in \(viewModel.currentMonth, formatter: viewModel.monthOnlyFormatter)")
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of CalendarViewModel for the preview
        SummaryView()
    }
}

