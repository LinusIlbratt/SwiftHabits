//
//  ContentView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var habitViewModel = HabitViewModel()
    @StateObject var weekdayPickerViewModel = WeekdayPickerViewModel()
    
    var body: some View {
        TabView {
            
            NavigationStack {
                HabitsView(habitViewModel: habitViewModel, weekdayPickerViewModel: weekdayPickerViewModel)
            }
            .tabItem {
                Label(LocalizedStringKey("Habits"), systemImage: "arrow.3.trianglepath")
            }

            
            NavigationStack {
                SummaryView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.xaxis")
            }
        }
    }
}

#Preview {
    ContentView()
}
