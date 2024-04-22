//
//  HabitsView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct HabitsView: View {
    @State private var selectedDay = "Mon"
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack {
            Picker("Choose day", selection: $selectedDay) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        Spacer()
    }
}

#Preview {
    HabitsView()
}
