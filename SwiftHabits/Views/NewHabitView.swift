//
//  NewHabitView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

struct NewHabitView: View {
    @Binding var isPresented: Bool
    @State private var habitName = ""
    @State private var specificTime = ""
    @State private var selectedIcon = ""
    @State private var frequency = "Daily"
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
                Text("Habit title")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                TextField("Enter habit name", text: $habitName)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal, 20)
                Text("Choose Image")
                    .font(.headline)
                    .padding()
                // card for icons
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 5)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.largeTitle)
                                .padding()
                                .background(self.selectedIcon == icon ? Color.blue : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    self.selectedIcon = icon
                                }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding()
                Text("Repeat")
                    .font(.headline)
                    .padding(.leading, 20)
                
                // repeat picker
                Picker("Frequency", selection: $frequency) {
                    ForEach(frequencyOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(1)))
                .padding(.horizontal)
                Text("Select Days")
                    .font(.headline)
                    .padding(.leading, 20)
                
                // day picker
                HStack {
                    ForEach(0..<days.count, id: \.self) { index in
                        Button(action: {
                            daysSelected[index].toggle()
                        }) {
                            Text(days[index])
                                .fontWeight(.medium)
                                .foregroundColor(daysSelected[index] ? .white : .black)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(daysSelected[index] ? Color.blue : Color.gray.opacity(0.2))
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
                
                // every day label and toggle
                HStack {
                    Text("Every day")
                        .font(.headline)
                        .padding(.leading, 20)
                    Spacer()
                    Toggle(isOn: $selectAllDays) {
                        EmptyView()
                    }
                    .onChange(of: selectAllDays) { _ in
                        for index in daysSelected.indices {
                            daysSelected[index] = selectAllDays
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.vertical)
                
                // time reminder and input
                HStack {
                    Text("Remind at specific time")
                        .font(.headline)
                        .padding(.leading, 20)
                    Spacer()
                    
                    TextField("8:00 AM", text: $specificTime)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .font(.subheadline)
                        .frame(width: 100)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)))
                        .padding(.trailing, 20)
                        }
                        .padding(.vertical)
                
                
                Spacer()
                
                Button("Add habit") {
                    isPresented = false
                }
                .padding()
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


struct NewHabitView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a binding by using .constant
        NewHabitView(isPresented: .constant(true))
    }
}
