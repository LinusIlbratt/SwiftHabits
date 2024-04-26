//
//  NewHabitView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

struct NewHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Binding var isPresented: Bool
    @State private var clockReminder = ""
    @State private var selectedIcon = ""
    @State private var frequency = ""
    @State private var daysSelected = Array(repeating: false, count: 7)
    @State private var selectAllDays = false
    
    var icons = [
        "flame.fill", "bolt.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "snow", "wind", "tornado"
    ]
    
    let frequencyOptions = ["Daily", "Weekly", "Monthly"]
    
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HabitTitel()
                
                // user input for habit name
                HabitNameInputView(habitName: $viewModel.habitName)
                
                // card for icons
                IconPicker(icons: icons, selectedIcon: $viewModel.selectedIcon)
                
                // repeat picker
                FrequencyPickerView(frequency: $frequency, frequencyOptions: frequencyOptions)
                
                // day picker
                DayPickerView(daysSelected: $daysSelected)
                
                // every day label and toggle
                EveryDayToggleView(selectAllDays: $selectAllDays, daysSelected: $daysSelected)
                
                // time reminder and input
                TimeReminderInputView(clockReminder: $viewModel.clockReminder)
                
                HStack {
                    Spacer()
                    Button("Add habit") {
                        // Set the viewModel properties with the current state before adding the habit
                        viewModel.habitName = viewModel.habitName  // Assuming you already bind this directly in a TextField
                        viewModel.iconName = selectedIcon
                        viewModel.frequency = frequency
                        viewModel.clockReminder = viewModel.clockReminder  // Ensure you have a UI element to set this or default it
                        viewModel.daysSelected = daysSelected

                        // Now call addHabit which uses these properties
                        viewModel.addHabit()
                        viewModel.resetFields()
                        isPresented = false  // Dismiss the view
                    }
                    .buttonStyle(CustomButtonStyle())
                    Spacer()
                }
            }
            .navigationBarTitle("Add New Habit", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}

struct HabitTitel: View {
    var body: some View {
        Text("Habit title")
            .font(.headline)
            .padding(.top, 20)
            .padding(.leading, 20)
    }
}

struct HabitNameInputView: View {
    @Binding var habitName: String

    var body: some View {
        TextField("Enter habit name", text: $habitName)
            .paddedTextFieldStyle()
            .padding(.horizontal, 10)            
    }
}

struct FrequencyPickerView: View {
    @Binding var frequency: String
    var frequencyOptions: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Repeat")
                .font(.headline)
                .padding(.leading, 20)

            Picker("Frequency", selection: $frequency) {
                ForEach(frequencyOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .customPickerStyle()
        }
    }
}

struct DayPickerView: View {
    @Binding var daysSelected: [Bool]
    let days: [String] = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack {
            ForEach(0..<days.count, id: \.self) { index in
                DayButton(isSelected: $daysSelected[index], label: days[index])
            }
        }
        .padding(.horizontal)
    }
}


struct EveryDayToggleView: View {
    @Binding var selectAllDays: Bool
    @Binding var daysSelected: [Bool]

    var body: some View {
        HStack {
            Text("Every day")
                .font(.headline)
                .padding(.leading, 20)
            Spacer()
            Toggle(isOn: $selectAllDays) {
                EmptyView()
            }
            .onChange(of: selectAllDays) { newValue in
                daysSelected = Array(repeating: newValue, count: daysSelected.count)
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical)
    }
}

struct TimeReminderInputView: View {
    @Binding var clockReminder: String

    var body: some View {
        HStack {
            Text("Remind at specific time")
                .font(.headline)
                .padding(.leading, 20)
            Spacer()
            TextField("8:00", text: $clockReminder)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .font(.subheadline)
                .frame(width: 100)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)))
                .padding(.trailing, 20)
        }
        .padding(.vertical)
    }
}


struct NewHabitView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of HabitViewModel
        let viewModel = HabitViewModel()
        
        // Create a preview of NewHabitView with necessary arguments
        NewHabitView(viewModel: viewModel, isPresented: .constant(true))
    }
}
