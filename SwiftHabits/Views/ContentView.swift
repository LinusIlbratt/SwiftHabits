//
//  ContentView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var habitViewModel = HabitViewModel()
    @StateObject var weekdayPickerViewModel = WeekdayPickerViewModel()
    let db = Firestore.firestore()
    
    var body: some View {
        TabView {
            
            NavigationStack {
                HabitsView(habitViewModel: habitViewModel, weekdayPickerViewModel: weekdayPickerViewModel)
            }
            .tabItem {
                Label(LocalizedStringKey("Habits"), systemImage: "arrow.3.trianglepath")
            }

            
            NavigationStack {
                // call view
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.xaxis")
            }
        }.onAppear() {
            db.collection("test").addDocument(data: ["name": "Linus"])
        }
    }
}

#Preview {
    ContentView()
}
