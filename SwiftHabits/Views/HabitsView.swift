//
//  HabitsView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct HabitsView: View {
    @ObservedObject var viewModel = WeekdayPickerViewModel()
    @State private var showingNewHabit = false
    
    let habits = [
        ("Walking", "Repeat everyday", "11:00 pm", 0.7),
        ("Reading", "20 pages a day", "9:00 pm", 0.5),
        ("Meditation", "Daily 15 minutes", "7:00 am", 0.9)
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(Array(zip(viewModel.days.indices, viewModel.days)), id: \.0) { index, day in
                    DayButtonView(day: day, date: viewModel.weekDates[index], isSelected: viewModel.selectedDayIndex == index, action: {
                        viewModel.selectedDayIndex = index
                    })
                }
            }
            .padding(.horizontal)
            Spacer()

            GoalCardView()

            VStack(alignment: .leading, spacing: 10) {
                HeaderTitleView(titleKey: "Today's Habits", paddingLeading: 20, paddingTop: 5)

                
                List(habits, id: \.0) { habit in
                    HabitCardView(habit: habit)
                }
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 10)
        }
        Spacer()
        
        Button(action: {
            showingNewHabit = true
        }, label: {
            Text("+ New habit")
                .padding()
        })
        .background(Color.blue)
        .cornerRadius(15)
        .foregroundColor(.white)
        .fullScreenCover(isPresented: $showingNewHabit) {
                        NewHabitView(isPresented: $showingNewHabit)
                    }
        Spacer()
    }
}

struct HeaderTitleView: View {
    var titleKey: LocalizedStringKey
    var paddingLeading: CGFloat
    var paddingTop: CGFloat

    var body: some View {
        Text(titleKey)
            .font(.system(size: 14, weight: .bold))
            .padding(.leading, paddingLeading)
            .padding(.top, paddingTop)
    }
}

struct GoalCardView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Daily Goal Almost Done")
                        .font(.headline)
                    Text("10 of 15 completed")
                        .font(.subheadline)
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    ProgressView(value: 80, total: 100)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 300, height: 20)
                    Text("80%")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .frame(width: 350, height: 80)

            Image("icon_bear")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(y: -50) 
        }
        .padding(.top, 20)
    }
}




struct HabitCardView: View {
    var habit: (String, String, String, Double)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(habit.0).habitTextStyle()
                Text(habit.1).font(.subheadline)
                Text(habit.2).font(.footnote)
            }
            .padding(.leading, 20)

            Spacer()

            ProgressView(value: habit.3, total: 1.0)
                .progressViewStyle(CircularProgressBarStyle(trackColor: .gray, progressColor: .blue, textColor: .black))
                .frame(width: 50, height: 50)
                .padding(.trailing, 20)
        }
        .frame(height: 80)
        .background(Color.white)
        .cardStyle()
    }
}

struct DayButtonView: View {
    var day: String
    var date: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(LocalizedStringKey(day)).habitTextStyle()
                Text(date)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .frame(minWidth: 44, minHeight: 60)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
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


extension View {
    func cardStyle() -> some View {
        self
            .cornerRadius(15)
            .shadow(radius: 5)
    }

    func habitTextStyle() -> some View {
        self
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.primary)
    }
}

#Preview {
    HabitsView()
}
