//
//  ContentView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            NavigationStack {
                HabitsView()
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
        }
    }
}

#Preview {
    ContentView()
}
