//
//  HabitService.swift
//  SwiftHabits
//
//  Created by Linus Ilbratt on 2024-05-07.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class HabitService {
    private var db = Firestore.firestore()

    func loadHabits(for userId: String, completion: @escaping ([Habit]?, Error?) -> Void) {
        let userHabitsPath = db.collection("users").document(userId).collection("habits")
        
        userHabitsPath.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let documents = snapshot?.documents else {
                completion(nil, NSError(domain: "HabitService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                return
            }
            let habits = documents.compactMap { document -> Habit? in
                try? document.data(as: Habit.self)
            }
            completion(habits, nil)
        }
    }
}
