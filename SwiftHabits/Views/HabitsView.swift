//
//  HabitsView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct HabitsView: View {
    @ObservedObject var viewModel = WeekdayPickerViewModel()

    var body: some View {
            HStack(spacing: 8) {
                ForEach(Array(zip(viewModel.days.indices, viewModel.days)), id: \.0) { index, day in
                    Button(action: {
                        viewModel.selectedDayIndex = index
                    }) {
                        VStack {
                            Text(LocalizedStringKey(day))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(viewModel.selectedDayIndex == index ? .white : .primary)
                            Text(viewModel.weekDates[index])
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.selectedDayIndex == index ? .white : .secondary)
                        }
                        .frame(minWidth: 44, minHeight: 60)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedDayIndex == index ? Color.blue : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        Spacer()
        }
}


#Preview {
    HabitsView()
}
