//
//  ContentView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct RootView: View {
    @StateObject var userViewModel = UserViewModel()

    var body: some View {
        if userViewModel.isLoggedIn {
            ContentView()
        } else {
            UserView().environmentObject(userViewModel)
        }
    }
}

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

struct UserView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var userViewModel: UserViewModel

        var body: some View {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Sign In") {
                    userViewModel.signIn(email: email, password: password)
                }
                Button("Sign Up") {
                    userViewModel.signUp(email: email, password: password)
                }
            }
            .padding()
        }
}

#Preview {
    RootView()
}
