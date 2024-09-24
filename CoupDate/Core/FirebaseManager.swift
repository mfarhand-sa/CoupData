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
    
    
    func streakRecords(for userId: String, from startDate: Date, to endDate: Date, completion: @escaping (Result<[Date: [String]], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Your document ID format

        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)

        db.collection("users").document(userId).collection("dailyRecords")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: startString)
            .whereField(FieldPath.documentID(), isLessThanOrEqualTo: endString)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching streak records for user \(userId): \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    var records: [Date: [String]] = [:]
                    for document in snapshot.documents {
                        if let date = dateFormatter.date(from: document.documentID) {
                            // Debug: Print the document data
                            print("Document ID: \(document.documentID), Data: \(document.data())")

                            // Fetch the 'status' array inside the 'mood' field
                            if let moodData = document.data()["mood"] as? [String: Any],
                               let statusArray = moodData["status"] as? [String] {
                                records[date] = statusArray // Store the status array for this date
                                // Debug: Print the status array found
                                print("Status for date \(date): \(statusArray)")
                            } else {
                                // No 'status' field found inside 'mood'
                                records[date] = [] // No status found, return an empty array
                                // Debug: Print that no status was found for this date
                                print("No status found for date \(date).")
                            }
                        }
                    }
                    completion(.success(records))
                } else {
                    print("No documents found in the specified date range for user \(userId).")
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
    
    
    func sendOTP(_ phoneNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        let functions = Functions.functions()
        functions.httpsCallable("sendOtp").call(["phoneNumber": phoneNumber]) { result, error in
            if let error = error {
                print("Error sending OTP: \(error)")
                completion(false, error)
                return
            }
            print("OTP sent successfully")
            completion(true, nil)
        }
    }

    
    
    
    func verifyOTP(_ otpCode: String, completion: @escaping (_ success: Bool, _ userNeedMoreData: Bool, _ userHasData: Bool, _ partnerHasData: Bool, _ error: Error?) -> Void) {
        let functions = Functions.functions()
        let phoneNumber = CDDataProvider.shared.countryCode! + CDDataProvider.shared.phoneNumber!

        functions.httpsCallable("verifyOtp").call(["phoneNumber": phoneNumber, "otpCode": otpCode]) { result, error in
            if let error = error {
                print("Error verifying OTP: \(error)")
                completion(false, false, false, false, error)
                return
            }

            if let data = result?.data as? [String: Any],
               let token = data["token"] as? String {
                // Use the custom token to authenticate with Firebase
                Auth.auth().signIn(withCustomToken: token) { authResult, error in
                    if let error = error {
                        print("Error signing in with custom token: \(error)")
                        completion(false, false, false, false, error)
                        return
                    }

                    // After signing in, load user data
                    CDDataProvider.shared.loadMyDataAndThenPartnerData { success, userNeedMoreData, userHasData, partnerHasData, error in
                        // Pass all the parameters from loadMyDataAndThenPartnerData to the completion handler
                        completion(success, userNeedMoreData, userHasData, partnerHasData, error)
                    }
                }
            } else {
                // Handle unexpected result
                completion(false, false, false, false, NSError(domain: "UnexpectedResult", code: -1, userInfo: nil))
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




    func getInsightsFromOpenRouter(formattedMoodData: String, completion: @escaping (String?) -> Void) {
        // Call the Firebase function
        let function = Functions.functions().httpsCallable("getInsightsFromOpenRouter")
        function.call(["formattedMoodData": formattedMoodData]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    print("Error: \(String(describing: code)) - \(message)")
                }
                completion(nil)
                return
            }
            
            // Handle the result
            if let data = result?.data as? [String: Any], let insights = data["insights"] as? String {
                print("Insights: \(insights)")
                completion(insights)
            } else {
                completion(nil)
            }
        }
    }




    
    func generateInsightsForAllUsers(completion: @escaping (Result<String, Error>) -> Void) {
        // Initialize the callable Firebase function
        let functions = Functions.functions()

        // Call the generateInsightsForAllUsers function
        functions.httpsCallable("generateInsightsForAllUsers").call { result, error in
            if let error = error {
                // Handle the error
                completion(.failure(error))
                return
            }
            
            // Check for the result and process it
            if let data = result?.data as? [String: Any], let message = data["message"] as? String {
                // Successful result
                completion(.success(message))
            } else {
                // Unexpected result format
                completion(.failure(NSError(domain: "Unexpected result format", code: 0, userInfo: nil)))
            }
        }
    }



        
        // Function to fetch moods based on gender
    func fetchMoods(for gender: String, completion: @escaping ([String]) -> Void) {
        
        let db = Firestore.firestore()
        
        var finalGender: String!
        if gender == "Male" {
            finalGender = "Man"
        } else {
            finalGender = "Woman"

        }
        
        var allMoods: [String] = []
                let group = DispatchGroup() // DispatchGroup to manage the asynchronous calls
                
                // Fetch general moods
                group.enter()
                db.collection("moods").document("general").getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let generalMoods = document.data()?["items"] as? [String] {
                            allMoods.append(contentsOf: generalMoods)
                        }
                    } else {
                        print("General document not found")
                    }
                    group.leave()
                }
                
                // Fetch gender-specific moods
                group.enter()
        db.collection("moods").document(finalGender).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let genderMoods = document.data()?["Items"] as? [String] {
                            allMoods.append(contentsOf: genderMoods)
                        }
                    } else {
                        print("\(gender) document not found")
                    }
                    group.leave()
                }
                // Notify when both fetches are done
                group.notify(queue: .main) {
                    // Returning combined mood data (general + gender-specific)
                    completion(allMoods)
                }
    }
    
    
    
    
    func sendADummyMSG() {
        let functions = Functions.functions()
        functions.httpsCallable("sendDummyNotification").call() { result, error in
            if let error = error as NSError? {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully.")
            }
        }
    }
    
    

}
