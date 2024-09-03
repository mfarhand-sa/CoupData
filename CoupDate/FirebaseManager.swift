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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
