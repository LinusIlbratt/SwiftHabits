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
            Spacer()
            ZStack {
                Text("Swift")
                    .font(.system(size: 122, weight: .black))
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 4)
                    
                Text("Habits")
                    .font(.system(size: 68, weight: .black))
                    .bold()
                    .foregroundColor(.blue.opacity(0.5))
                    .rotationEffect(.degrees(-10))
                    .offset(x: 70, y: 50)
            }
            

            TextField("Email", text: $email)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .shadow(radius: 3)
                .padding(.horizontal, 24)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .shadow(radius: 3)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            Button(action: {
                userViewModel.signIn(email: email, password: password)
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }

            Button(action: {
                userViewModel.signUp(email: email, password: password)
            }) {
                Text("Sign Up")
                    .foregroundColor(.blue)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
            }
            Spacer()
        }
        .alert(isPresented: Binding<Bool>(
            get: { self.userViewModel.errorMessage != nil },
            set: { _ in self.userViewModel.errorMessage = nil }
        ), content: {
            Alert(title: Text("Error"), message: Text(userViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        })
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}

//#Preview {
//    RootView()
//}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView().environmentObject(UserViewModel())
    }
}
