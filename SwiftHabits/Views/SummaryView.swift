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
            
            HabitSummaryView(viewModel: habitViewModel)
            
            HStack{
                CardView()
                CardView()
            }
            
            HStack{
                CardView()
                CardView()
            }
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
    @ObservedObject var viewModel: HabitViewModel
    @State private var selectedSegment = 0

    var body: some View {
        VStack {
            Picker("Habits", selection: $selectedSegment) {
                ForEach(0..<viewModel.habits.count, id: \.self) { index in
                    Text(viewModel.habits[index].name).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Display details based on the selected habit
            if !viewModel.habits.isEmpty {
                Text("Selected Habit: \(viewModel.habits[selectedSegment].name)")
            }
        }
    }
}


struct CardView: View {
    var body: some View {
        // Your card implementation goes here
        Text("Card View")
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

