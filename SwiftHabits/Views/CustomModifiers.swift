//
//  CustomModifiers.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

struct PaddedTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
    }
}

struct DayButton: View {
    @Binding var isSelected: Bool
    let label: String

    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(15)
        }
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

struct CustomPickerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(1)))
            .padding(.horizontal)
    }
}
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension View {
    func paddedTextFieldStyle() -> some View {
        self.modifier(PaddedTextFieldStyle())
    }
}

extension View {
    func customPickerStyle() -> some View {
        self.modifier(CustomPickerStyle())
    }
}

extension View {
    func uniformPadding() -> some View {
        self.padding(.horizontal, 20)
           .padding(.vertical, 10)
    }
}
