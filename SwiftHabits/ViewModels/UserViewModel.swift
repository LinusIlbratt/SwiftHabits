//
//  UserViewModel.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-02.
//

import Foundation
import FirebaseAuth
import Combine

class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Login failed: \(error.localizedDescription)"
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = nil // Clear previous errors
                }
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Registration failed: \(error.localizedDescription)"
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = nil // Clear previous errors
                }
            }
        }
    }
}
