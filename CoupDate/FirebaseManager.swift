//
//  FirebaseManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import Foundation
import Firebase




class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Save a daily record
    func saveDailyRecord(for userId: String, date: Date, poopStatus: String, poopDetails: String, sleepStatus: String, sleepDetails: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let dateString = dateFormatter.string(from: date)
        
        let data: [String: Any] = [
            "poop": [
                "status": poopStatus,
                "details": poopDetails
            ],
            "sleep": [
                "status": sleepStatus,
                "details": sleepDetails
            ],
            "date": Timestamp(date: date)
        ]
        
        db.collection("users").document(userId).collection("dailyRecords").document(dateString)
            .setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // Load a daily record
    func loadDailyRecord(for userId: String, date: Date, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let dateString = dateFormatter.string(from: date)
        
        db.collection("users").document(userId).collection("dailyRecords").document(dateString)
            .getDocument { document, error in
                if let document = document, document.exists {
                    completion(.success(document.data() ?? [:]))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success([:]))
                }
            }
    }
    
    
    
    


    func updateUserProfile(userID: String, firstName: String, birthday: Date!, partnerUserID: String?,completion: @escaping (Result<Bool, Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Convert Date to a string or timestamp
        
        var userData = [String: Any]()
        
        if let birthday = birthday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Format as needed
            let birthdayString = dateFormatter.string(from: birthday)
            userData["birthday"] = birthdayString
        }
        // Data to update
        
        userData["firstName"] = firstName

        
        // Add partnerUserID to userData if it is not nil
        if let partnerID = partnerUserID {
            userData["partnerUserID"] = partnerID
        }
        
        // Update the document with the new fields
        db.collection("users").document(userID).updateData(userData) { error in
            if let error = error {
                print("Error updating user profile: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User profile updated successfully.")
                completion(.success(true))
            }
        }
    }


    

    
    func fetchUserProfile(userID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    

    
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    

    func savePartnerUserId(_ partnerUserId: String,completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        
        // Save partnerUserId to the current user's record
        db.collection("users").document(currentUserId).setData(["partnerUserId": partnerUserId], merge: true) { error in
            if let error = error {
                print("Error updating current user's partnerUserId: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            print("Current user's partnerUserId updated successfully")
        }
        
        // Save currentUserId to the partner's record
        db.collection("users").document(partnerUserId).setData(["partnerUserId": currentUserId], merge: true) { error in
            if let error = error {
                print("Error updating partner's userId: \(error.localizedDescription)")
                return
            }
            print("Partner's userId updated successfully")
            completion(.success(true))

        }
    }
    
    
    
    
}
