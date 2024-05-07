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
    var dayCompleted: [Date]  

    var body: some View {
        VStack {
            HStack {
                Button(action: viewModel.moveToPreviousMonth) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }

                Text("\(viewModel.currentMonth, formatter: viewModel.monthYearFormatter)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Button(action: viewModel.moveToNextMonth) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            
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
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
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
            
            let daysCompletedInMonth = dayCompleted.filter { date in
                let monthYearFormatter = DateFormatter()
                monthYearFormatter.dateFormat = "yyyy MM"
                return monthYearFormatter.string(from: date) == monthYearFormatter.string(from: viewModel.currentMonth)
            }.count
            
            
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
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding()
            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)
            
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
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding()
            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)
            
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
            VStack(spacing: 4) {
                Text("Current streak")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.4))
                
                Text("\(streakCount)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding()
            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)
            
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
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
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .padding()
            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)

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
