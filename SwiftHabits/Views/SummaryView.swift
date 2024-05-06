//
//  SummaryView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-01.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @ObservedObject var habitViewModel: HabitViewModel
    @State private var selectedSegment = 0

    var body: some View {
            VStack {
                if !habitViewModel.habits.isEmpty {
                    CalendarView(viewModel: calendarViewModel, dayCompleted: habitViewModel.habits[selectedSegment].dayCompleted)
                } else {
                    CalendarView(viewModel: calendarViewModel, dayCompleted: [])
                }
                
                Spacer()
                
                HabitSummaryView(viewModelHabit: habitViewModel, viewModelCalendar: calendarViewModel, selectedSegment: $selectedSegment)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        }
    }

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var dayCompleted: [Date]  // Now properly passed from SummaryView

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
            
            MonthView(viewModel: viewModel, dayCompleted: dayCompleted)
        }
    }
}

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var dayCompleted: [Date]

    var body: some View {
        let metadata = viewModel.monthMetadata()
        let firstDayWeekday = viewModel.firstDayOfWeekday()
        let weekdays = viewModel.weekdays
        let firstDayOfMonth = metadata.firstDay 

        return VStack {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }

            // Day grid
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0..<42, id: \.self) { index in
                    if index < firstDayWeekday || index >= firstDayWeekday + metadata.numberOfDays {
                        Text("")
                            .frame(width: 40, height: 40)
                    } else {
                        let dayOffset = index - firstDayWeekday
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth)!

                        DayCell(date: date, isActive: dayCompleted.contains { Calendar.current.isDate($0, inSameDayAs: date) })
                    }
                }
            }
        }
    }
}

struct DayCell: View {
    var date: Date
    var isActive: Bool

    var body: some View {
            Text("\(Calendar.current.component(.day, from: date))")
                .frame(width: 40, height: 40)
                .background(isActive ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(10) // Apply rounded corners directly to the background
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // Apply rounded rectangle overlay
                        .stroke(Color.gray, lineWidth: 0.1)
                )
        }
}

struct HabitSummaryView: View {
    @ObservedObject var viewModelHabit: HabitViewModel
    @ObservedObject var viewModelCalendar: CalendarViewModel
    @Binding var selectedSegment: Int

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
                // Ensure that the dayCompleted data from the correct habit is passed
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

struct DaysDoneInMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var dayCompleted: [Date]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Compute the count of dates in the current month
            let daysCompletedInMonth = dayCompleted.filter { date in
                let monthYearFormatter = DateFormatter()
                monthYearFormatter.dateFormat = "yyyy MM"
                return monthYearFormatter.string(from: date) == monthYearFormatter.string(from: viewModel.currentMonth)
            }.count
            
            // Display the count and the month name
            VStack {
                Text("Days done in \(viewModel.currentMonth, formatter: viewModel.monthOnlyFormatter)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.4))
                Text("\(daysCompletedInMonth)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .padding()
            .shadow(radius: 3)
            
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
                .offset(y: 5)
        }
    }
}

struct TotalCompletionsView: View {
    var totalCompletions: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 4) {
                Text("Total days done")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.4))
                
                Text("\(totalCompletions)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .padding()
            .shadow(radius: 3)
            
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gold)
        }
    }
    
}


struct StreakCountView: View {
    var streakCount: Int

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 4) { // Reduced spacing between the texts
                Text("Current streak")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.4))
                
                Text("\(streakCount)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Apply frame to contain the entire VStack
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .padding()
            .shadow(radius: 3)
            
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
               // .offset(y:)
        }
    }
}

struct LongestStreakView: View {
    var longestStreak: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 4) {
                Text("Best streak")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.4))
                
                Text("\(longestStreak)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(1)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(10)
            .padding()
            .shadow(radius: 3)

            // Place the crown icon
            Image(systemName: "crown.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.yellow)
                .offset(y: -5)
        }
    }
}

extension Color {
    static let gold = Color(red: 0.83, green: 0.69, blue: 0.22)
}



struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of CalendarViewModel for the preview
        SummaryView(habitViewModel: HabitViewModel())
    }
}
