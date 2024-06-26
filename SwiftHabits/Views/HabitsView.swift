//
//  HabitsView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-22.
//

import SwiftUI

struct HabitsView: View {
    @StateObject var habitViewModel: HabitViewModel
    @StateObject var weekdayPickerViewModel: WeekdayPickerViewModel
    @State private var showingNewHabit = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(Date(), style: .date)
                .font(.title3.bold())
            WeekdayPickerView(weekdayPickerViewModel: weekdayPickerViewModel)
            Spacer()
            GoalCardView(viewModel: habitViewModel)
            HabitListView(viewModel: habitViewModel, weekdayPickerViewModel: weekdayPickerViewModel)
            Spacer()
            NewHabitButton(showingNewHabit: $showingNewHabit, viewModel: habitViewModel)
            Spacer()
        }
        .environmentObject(habitViewModel)
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
    }
}

struct WeekdayPickerView: View {
    @ObservedObject var weekdayPickerViewModel: WeekdayPickerViewModel

    var body: some View {
        let dateStrings = weekdayPickerViewModel.datesForWeek

        HStack(spacing: 8) {
            ForEach(Array(zip(weekdayPickerViewModel.days.indices, weekdayPickerViewModel.days)), id: \.0) { index, day in
                DayButtonView(day: day,
                              date: dateStrings[index],
                              isSelected: weekdayPickerViewModel.selectedDayIndex == index)
            }
        }
        .padding(.horizontal)
    }
}




struct GoalCardView: View {
    @ObservedObject var viewModel: HabitViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Daily Goals")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Dynamically display the number of completed habits out of the total
                    Text("\(viewModel.filteredHabits.filter { $0.progress == 1.0 }.count) of \(viewModel.filteredHabits.count) completed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    // Calculate the progress based on completed habits
                    let progressValue = Double(viewModel.filteredHabits.filter { $0.progress == 1.0 }.count)
                    let progressTotal = Double(viewModel.filteredHabits.count)
                    let progressPercentage = progressTotal > 0 ? (progressValue / progressTotal) * 100 : 0
                    
                    ProgressView(value: progressValue, total: progressTotal)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(width: 330, height: 20)
                        .cornerRadius(20)
                    Text("\(Int(progressPercentage))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .frame(width: 350, height: 80)

            Image("icon_bear") // Ensure this image is available in your assets
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(y: -60)
        }
        .padding(.top, 20)
    }
}



struct HabitListView: View {
    @ObservedObject var viewModel: HabitViewModel
    @ObservedObject var weekdayPickerViewModel: WeekdayPickerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeaderTitleView(titleKey: "Today's Habits", paddingLeading: 20, paddingTop: 5)
            List {
                ForEach($viewModel.filteredHabits, id: \.id) { $habit in
                    HabitCardView(habit: $habit)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: removeHabits)
            }
            .listStyle(PlainListStyle())
            .disabled(!weekdayPickerViewModel.isTodaySelected())
        }
        .padding(.horizontal, 10)
        .onAppear {
            weekdayPickerViewModel.updateWeekDates()  // Recalculate week dates if necessary
        }
    }
    
    private func removeHabits(at offsets: IndexSet) {
            viewModel.removeHabit(at: offsets)
        }
}




struct HabitCardView: View {
    @Binding var habit: Habit // use Binding to allow modification
    @EnvironmentObject var viewModel: HabitViewModel
    
    var body: some View {
        HStack {
            Image(systemName: habit.iconName)
                .font(.title)
                .foregroundColor(.blue)
                .padding(.leading, 20)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 5) {
                Text(habit.name)
                    .font(.headline)
                
                Text("Reminder at")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(habit.clockReminder)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // add more properties from Habit here
            }
            Spacer()
            
            if habit.streakCount >= 4 {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(.trailing, 10)
            }
            
            ProgressView(value: habit.progress, total: habit.progress)
                .progressViewStyle(CircularProgressBarStyle(trackColor: .gray, progressColor: .blue, textColor: .black))
                .frame(width: 50, height: 50)
                .padding(.trailing, 20)
        }
        .frame(height: 100)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.blue.opacity(0.2), radius: 12)
       // .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 10, y: 10)
        .onTapGesture {
            withAnimation {
                habit.progress = 1.0
                viewModel.completeHabit(to: habit.id ?? "")
            }
        }
    }
}

struct NewHabitButton: View {
    @Binding var showingNewHabit: Bool
    var viewModel: HabitViewModel

    var body: some View {
        Button(action: {
            showingNewHabit = true
        }, label: {
            Text("+ New habit")
                .padding()
        })
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(10)
        .foregroundColor(.white)
        .fullScreenCover(isPresented: $showingNewHabit) {
            NewHabitView(viewModel: viewModel, isPresented: $showingNewHabit)
        }
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


struct DayButtonView: View {
    var day: String
    var date: String
    var isSelected: Bool

    var body: some View {
        VStack {
            Text(LocalizedStringKey(day))
                .habitTextStyle()
            Text(date)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .white : .secondary)
        }
        .frame(minWidth: 44, minHeight: 55)
        .background(isSelected ? Color.blue.opacity(0.6) : Color.blue.opacity(0.15))
        .cornerRadius(8)
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
    HabitsView(habitViewModel: HabitViewModel(), weekdayPickerViewModel: WeekdayPickerViewModel())
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default color: Black
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
