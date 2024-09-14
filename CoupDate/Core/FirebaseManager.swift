//
//  FirebaseManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import Foundation
import Firebase
import FirebaseFunctions




class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Save a daily record
    func saveDailyRecord(for userId: String, date: Date, category: String, statuses: [String], details: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let dateString = dateFormatter.string(from: date)
        
        if statuses.count == 1 {
            let firstOption = statuses.first
            print("The first (and only) option is: \(firstOption ?? "None")")
        }
        
        // Prepare the data structure for the specific category with multiple statuses
        let data: [String: Any] = [
            category: [
                "status": statuses,  // An array of statuses
                "details": details
            ],
            "date": Timestamp(date: date)
        ]
        
        // Update the specific category in Firestore using merge: true to prevent overwriting other fields
        db.collection("users").document(userId).collection("dailyRecords").document(dateString)
            .setData(data, merge: true) { error in
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
                    completion(.success([:])) //TODO: Double check if we don't have to call the  completion(.success([:])) and we should call completion(.failure(error))
                }
            }
    }
    
    
    func streakRecords(for userId: String, from startDate: Date, to endDate: Date, completion: @escaping (Result<[Date: Bool], Error>) -> Void) {
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd" // Your document ID format

           let startString = dateFormatter.string(from: startDate)
           let endString = dateFormatter.string(from: endDate)

           db.collection("users").document(userId).collection("dailyRecords")
               .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: startString)
               .whereField(FieldPath.documentID(), isLessThanOrEqualTo: endString)
               .getDocuments { snapshot, error in
                   if let error = error {
                       completion(.failure(error))
                   } else if let snapshot = snapshot {
                       var records: [Date: Bool] = [:]
                       for document in snapshot.documents {
                           if let date = dateFormatter.date(from: document.documentID) {
                               records[date] = true // Record exists for this date
                           }
                       }
                       completion(.success(records))
                   } else {
                       completion(.success([:])) // No records found
                   }
               }
    }

    
    
    
    


    func updateUserProfile(userID: String, firstName: String, birthday: Date!, partnerUserID: String?,gender: String? = nil,completion: @escaping (Result<Bool, Error>) -> Void) {
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
            userData["partnerUserId"] = partnerID
        }
        
        if let gender = gender {
            userData["gender"] = gender
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
                completion(.success(["" : ""]))

//                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
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
    
    
    func pairUsersWithToken(token: String,completion: @escaping (Result<Bool, Error>) -> Void) {
        let functions = Functions.functions()
        
        functions.httpsCallable("validateInvitationAndPairUsers").call(["partnerCode": token]) { result, error in
            if let error = error {
                print("Error during pairing: \(error.localizedDescription)")
                // Handle error (e.g., show alert to user)
                completion(.failure(error))
            } else if let data = result?.data as? [String: Any], let success = data["success"] as? Bool, success {
                print("Users have been successfully paired")
                // Handle success (e.g., update UI or navigate to main screen)
                
                if let receiverTmpPartnerId = data["receiverPartnerUserId"] as? String {
                    
                    UserManager.shared.partnerUserID = receiverTmpPartnerId
                    CDDataProvider.shared.partnerID = receiverTmpPartnerId
                }
                
                
                completion(.success(true))

            }
        }
    }
    
    
    func sendMessageToPartner(partnerUid: String, message: String, messageType: String) {
        let functions = Functions.functions()
        let data: [String: Any] = ["partnerUid": partnerUid, "message": message, "messageType": messageType]

        functions.httpsCallable("sendPartnerMessage").call(data) { result, error in
            if let error = error as NSError? {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully.")
            }
        }
    }
    
    
    func sendTestMessageToSelf() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let functions = Functions.functions()
        let data: [String: Any] = [
            "partnerUid": currentUserUid, // Sending to yourself
            "message": "This is a test message",
            "messageType": "text"
        ]

        functions.httpsCallable("sendPartnerMessage").call(data) { result, error in
            if let error = error as NSError? {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Test message sent successfully.")
            }
        }
    }
    


    
    

    func deleteMessage(messageId: String) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }

        let messageRef = Firestore.firestore().collection("users").document(currentUserUid).collection("messages").document(messageId)

        messageRef.delete { error in
            if let error = error {
                print("Error deleting message: \(error.localizedDescription)")
            } else {
                print("Message deleted successfully.")
            }
        }
    }



    
    
    
    
}
