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
    @State private var selectedIcon = ""
    
    var icons = [
        "flame.fill", "bolt.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "snow", "wind", "tornado"
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {  // Alignment till .leading
                Text("Habit title")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 20)  // Lägg till padding till vänster för att justera texten
                
                TextField("Enter habit name", text: $habitName)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
                    .padding(.horizontal, 20)
                Text("Choose Image")
                    .font(.headline)
                    .padding()
                // Card för ikoner
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)  // Vit bakgrund för kortet
                        .shadow(radius: 5)  // Skugga för att skapa "elevated" effekt
                    
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
                    .padding()
                }
                .padding()
                Text("Repeat")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button("Stäng") {
                    isPresented = false
                }
                .padding()
            }
            .navigationBarTitle("Add New Habit", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isPresented = false  // Stänger vyn
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
