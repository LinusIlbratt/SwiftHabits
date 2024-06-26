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
    
    func addHabit(habit: Habit, userId: String, completion: @escaping (Bool) -> Void) {
        guard let habitId = habit.id else {
            print("Habit ID is nil")
            completion(false)
            return
        }
        
        let userHabitPath = db.collection("users").document(userId).collection("habits").document(habitId)
        do {
            try userHabitPath.setData(from: habit) { error in
                completion(error == nil)
            }
        } catch {
            print("Error serializing habit: \(error)")
            completion(false)
        }
    }

    func updateHabit(habit: Habit, userId: String, completion: @escaping (Bool) -> Void) {
        guard let habitId = habit.id else {
            print("Habit ID is nil")
            completion(false)
            return
        }
        
        let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
        habitRef.updateData([
            "streakCount": habit.streakCount,
            "progress": habit.progress,
            "totalCompletions": habit.totalCompletions,
            "totalAttempts": habit.totalAttempts,
            "longestStreak": habit.longestStreak,
            "dayCompleted": habit.dayCompleted.map { Timestamp(date: $0) },
            "isDone": habit.isDone
        ]) { error in
            completion(error == nil)
        }
    }
    
    func updateCompletedHabit(userId: String, habitId: String, habit: Habit, completion: @escaping (Bool) -> Void) {
        let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
        let updateData: [String: Any] = [
            "streakCount": habit.streakCount,
            "progress": habit.progress,
            "totalCompletions": habit.totalCompletions,
            "totalAttempts": habit.totalAttempts,
            "longestStreak": habit.longestStreak,
            "dayCompleted": habit.dayCompleted.map { Timestamp(date: $0) },  // Ensure correct date conversion
            "isDone": habit.isDone
        ]
        habitRef.updateData(updateData) { error in
            completion(error == nil)
        }
    }
    
    func updateTotalAttemptsForHabit(userId: String, habitId: String, attempts: Int, completion: @escaping (Bool) -> Void) {
            let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
            habitRef.updateData(["totalAttempts": attempts]) { error in
                if let error = error {
                    print("Error updating total attempts: \(error)")
                    completion(false)
                } else {
                    print("Total attempts successfully updated for Habit ID: \(habitId)")
                    completion(true)
                }
            }
        }

    
    func resetHabitProgress(userId: String, habit: Habit, completion: @escaping (Bool) -> Void) {
            guard let habitId = habit.id else {
                completion(false)
                return
            }
            let userHabitRef = db.collection("users").document(userId).collection("habits").document(habitId)
            userHabitRef.updateData([
                "isDone": habit.isDone,
                "progress": habit.progress
            ]) { error in
                if let error = error {
                    print("Error updating habit: \(error)")
                    completion(false)
                } else {
                    print("Habit successfully updated with reset values for habit ID: \(habitId)")
                    completion(true)
                }
            }
        }
    
    func removeHabitFromDatabase(userId: String?, habit: Habit, habitId: String, completion: @escaping (Bool) -> Void) {
            guard let userId = userId else {
                completion(false)
                return
            }
            db.collection("users").document(userId).collection("habits").document(habitId).delete { error in
                if let error = error {
                    print("Error removing habit: \(error)")
                    completion(false)
                } else {
                    NotificationService.shared.removeNotifications(for: habit.name)
                    completion(true)
                }
            }
        }

    
    func updateStreakCount(for habit: Habit, userId: String, completion: ((Error?) -> Void)?) {
            guard let habitId = habit.id else { return }
            let habitRef = db.collection("users").document(userId).collection("habits").document(habitId)
            habitRef.updateData(["streakCount": habit.streakCount]) { error in
                completion?(error)
            }
        }

        func updateTotalAttempts(for habit: Habit, userId: String, completion: ((Error?) -> Void)?) {
            guard let habitId = habit.id else { return }
            let userHabitRef = db.collection("users").document(userId).collection("habits").document(habitId)
            userHabitRef.updateData(["totalAttempts": habit.totalAttempts]) { error in
                completion?(error)
            }
        }
}
