//
//  HabitsView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct HabitsView: View {
    @ObservedObject var viewModel = WeekdayPickerViewModel()
    
    let habits = [
        ("Walking", "Repeat everyday", "11:00 pm", 0.7),
        ("Reading", "20 pages a day", "9:00 pm", 0.5),
        ("Meditation", "Daily 15 minutes", "7:00 am", 0.9)
    ]

    var body: some View {
        VStack(spacing: 20) {
            
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
            ZStack(alignment: .top) {
                            // CardView
                            VStack(alignment: .trailing, spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Your Daily Goal Almost Done")
                                        .font(.headline)
                                    Text("10 of 15 completed")
                                        .font(.subheadline)
                                }
                                VStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        ProgressView(value: 80, total: 100)
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .frame(width: 230, height: 20)
                                    }
                                    HStack {
                                        Spacer()
                                        Text("80%")
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .frame(width: 350, height: 80)

                            Image("icon_bear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .offset(x: -120)
                                .offset(y: -50)
                        }
                        .padding(.top, 20)

            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Habits")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.leading, 20)
                    .padding(.top, 5)

                List(habits, id: \.0) { habit in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(habit.0)
                                .font(.headline)
                            Text(habit.1)
                                .font(.subheadline)
                            Text(habit.2)
                                .font(.footnote)
                        }
                        .padding(.leading, 20)

                        Spacer()

                        ProgressView(value: habit.3, total: 1.0)
                            .progressViewStyle(CircularProgressBarStyle(trackColor: .gray, progressColor: .blue, textColor: .black))
                            .frame(width: 50, height: 50)
                            .padding(.trailing, 40)
                    }
                    .frame(height: 100)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 10)
                    }
                    Spacer()
                }
            }

struct CircularProgressBarStyle: ProgressViewStyle {
    var trackColor: Color
    var progressColor: Color
    var textColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(trackColor)
            
            Circle()
                .trim(from: 0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: configuration.fractionCompleted)
            
            Text("\(Int((configuration.fractionCompleted ?? 0) * 100))%")
                .font(.caption)
                .foregroundColor(textColor)
        }
    }
}




#Preview {
    HabitsView()
}
