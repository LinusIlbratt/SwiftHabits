//
//  NewHabitView.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-04-23.
//

import SwiftUI

struct NewHabitView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                Text("Lägg till ny vana här.")
                Spacer()
                Button("Add Habit") {
                    isPresented = false  // Stänger fullScreenCover
                }
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
