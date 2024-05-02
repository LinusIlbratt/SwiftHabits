//
//  UserViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-02.
//

import Foundation
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                print("Error signing in: \(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.isLoggedIn = true
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                print("Error creating user: \(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.isLoggedIn = true
            }
        }
    }
}
