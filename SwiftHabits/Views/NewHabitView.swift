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

    var icons = [
        "figure.walk", "bolt.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "figure.run", "dumbbell.fill", "figure.open.water.swim"
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
                FrequencyPickerView(frequency: $viewModel.frequency, frequencyOptions: frequencyOptions)
                
                // day picker
                DayPickerView(daysSelected: $viewModel.daysSelected, days: days)
                
                // every day label and toggle
                EveryDayToggleView(selectAllDays: $viewModel.selectAllDays, daysSelected: $viewModel.daysSelected)
                
                // time reminder and input
                TimeReminderInputView(clockReminder: $viewModel.clockReminder)
                
                HStack {
                    Spacer()
                    Button("Add Habit") {
                        viewModel.addHabit()  // Uses properties directly from the ViewModel
                        isPresented = false  // Dismiss the view
                    }
                    .buttonStyle(CustomButtonStyle())
                    Spacer()
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
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

struct IconPicker: View {
    let icons: [String]
    @Binding var selectedIcon: String
    
    var body: some View {
        Text("Choose Image")
            .font(.headline)
            .padding()
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 5)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .padding()
                        .background(selectedIcon == icon ? Color.blue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            selectedIcon = icon
                        }
                }
            }
            .padding(.top, 5)
        }
        .padding(.horizontal, 20)
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
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct DayPickerView: View {
    @Binding var daysSelected: [Bool]
    let days: [String]

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
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    @State private var isPopoverPresented = false
    @State private var popoverSize: CGSize = .zero

    var body: some View {
        VStack {
            HStack {
                Text("Remind at specific time")
                    .font(.headline)
                    .padding(.leading, 20)

                Spacer()

                Button(action: {
                    self.isPopoverPresented.toggle()
                }) {
                    Text(clockReminder.isEmpty ? "8:00" : clockReminder)
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)))
                .padding(.trailing, 20)
            }
            .padding(.vertical)

            ZStack {
                if isPopoverPresented {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isPopoverPresented.toggle()
                        }

                    VStack {
                        timePickerView()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            self.popoverSize = geometry.size
                                        }
                                }
                            )
                            .offset(y: -popoverSize.height / 2)
                            .animation(.default)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: popoverSize.height)
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    @ViewBuilder
    private func timePickerView() -> some View {
        VStack {
            Text("Choose Time")
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(0...23, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
                .clipped()

                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0...59, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 150)
                .clipped()
            }

            Button("Set reminder") {
                clockReminder = String(format: "%02d:%02d", selectedHour, selectedMinute)
                isPopoverPresented = false
            }
            .padding(.top, 10)
        }
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
