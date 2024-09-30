//
//  CDDataProvider.swift
//  CoupDate
//
//  Created by mo on 2024-09-04.
//

import Foundation


// Mark: - CDDataProvider

/// Tripper Data Provider is responsible to populate data
///
class CDDataProvider {
    
    static let shared = CDDataProvider()
    public var partnerID: String?
    public var name: String?
    public var birthday: Date?
    public var gender: String?
    public var phoneNumber, countryCode: String?
    var dailyRecords: [Date: (userMoods: [String], partnerMoods: [String])]?
    var streak : Int?
    var startDate : Date?
    var endDate : Date?
    var insights: String?
    var smart_Insight: [String: String]?

    
    var moods: [String]?


    



    
    
    // Stored data properties
    var userData: [String: Any]?
    var partnerData: [String: Any]?
    
    
    var poopData: [String: Any]?
    var sleepData: [String: Any]?
    var moodData: [String: Any]?
    var energyData: [String: Any]?


    
    private init() {
    }
    
    /// Reset method will reset all the properties and it'll be used after logout or delete account
    public func reset() {}
    
    
    func generatePairingLink(forUserId userId: String) -> URL? {
        return URL(string: "https://mytripper.app/pair?partnerUserId=\(userId)")
    }
    
    
    
    // Check if the user needs registration
    func checkUserRegistrationStatus(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.fetchUserProfile(userID: UserManager.shared.currentUserID!) { result in
            switch result {
            case .success(let data):
                self.userData = data
                let needsRegistration = data["firstName"] == nil || data["birthday"] == nil
                completion(needsRegistration)
            case .failure:
                completion(true) // Assume registration is needed if there's an error
            }
        }
    }
    
    
    // Load partner data
    func loadPartnerData(partnerID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        FirebaseManager.shared.loadDailyRecord(for: partnerID, date: Date()) { result in
            switch result {
            case .success(let data):
                self.partnerData = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fetch user profile
    func fetchUserProfile(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        FirebaseManager.shared.fetchUserProfile(userID: UserManager.shared.currentUserID!, completion: completion)
    }
    
    
    
    
    
    // Method to load user and then partner data
    func loadMyDataAndThenPartnerData(completion: @escaping (_ success : Bool, _ userNeedMoreData: Bool, _ userData: Bool, _ partnerData: Bool,_ errorInfo: Error?) -> Void) {
        
        
        var success = false
        var userNeedMoreData = true
        var userHasData = false
        var partnerHasData = false
        
        
        
        FirebaseManager.shared.fetchUserProfile(userID: UserManager.shared.currentUserID!) { result in
            switch result {
                
                
            case .success(let data):
                self.userData = data
                userHasData = true
                self.name = data["firstName"] as? String
                self.gender = data["gender"] as? String
                
                if let partnerID = data["partnerUserId"] as? String {
                    self.partnerID = partnerID
                    UserManager.shared.partnerUserID = partnerID
                    
                    if let insight = data["insight"] as? String {
                        CDDataProvider.shared.insights = insight
                    }
                    
                    if let smartInsight = data["Smart_Insight"] as? [String: String] {
                        // Return the insights (My_Insight, Partner_Insight, Relationship_Insight)
                        CDDataProvider.shared.smart_Insight = smartInsight
                        
                    } else {
                        print("Smart_Insight field is missing.")
                    }
                    
                    self.loadPartnerData(partnerID: partnerID) { result in
                        switch result {
                        case .success(let partnerData):
                            self.partnerData = partnerData
                            self.updatePartnerData()
                            partnerHasData = true
                            break
                            
                        case .failure(let error):
                            print(error);
                            
                        }
                    }
                    
                }
                
                
                // Check if user profile is incomplete
                userNeedMoreData = data["firstName"] == nil || data["birthday"] == nil || data["gender"] == nil
                
                completion(true,userNeedMoreData,userHasData,partnerHasData,nil)
                
                break
                
            case .failure(let error):
                
                completion(false, false, false, false,error)
                break
            }
            
        }
    }
    
    // Method to load partner data using partner ID
    func loadPartnerData(partnerID: String, completion: @escaping (Bool, String?) -> Void) {
        FirebaseManager.shared.loadDailyRecord(for: partnerID, date: Date()) { result in
            switch result {
            case .success(let data):
                self.partnerData = data
                completion(true, nil)
            case .failure(let error):
                completion(false, "Error loading partner data: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
    
    func loadAllUserAndPartnerData(userID: String, partnerID: String, daysToCheck: Int = 30, completion: @escaping (Int?, Date?, Date?, [Date: (userMoods: [String], partnerMoods: [String])], Error?) -> Void) {
        let endDate = Date() // Fixed typo
        let startDate = Calendar.current.date(byAdding: .day, value: -daysToCheck, to: endDate)!

        FirebaseManager.shared.streakRecords(for: userID, from: startDate, to: endDate) { userResult in
            switch userResult {
            case .success(let userRecords):
                FirebaseManager.shared.streakRecords(for: partnerID, from: startDate, to: endDate) { partnerResult in
                    switch partnerResult {
                    case .success(let partnerRecords):
                        var combinedRecords: [Date: (userMoods: [String], partnerMoods: [String])] = [:]

                        // Combine user and partner records into a single dictionary
                        let allDates = Array(Set(userRecords.keys).union(Set(partnerRecords.keys)))
                        for date in allDates {
                            let userMoods = userRecords[date] ?? []
                            let partnerMoods = partnerRecords[date] ?? []
                            combinedRecords[date] = (userMoods: userMoods, partnerMoods: partnerMoods)
                        }

                        // Calculate the streak count using the updated calculateStreak method
                        let streakCount = self.calculateStreak(userRecords: userRecords, partnerRecords: partnerRecords)
                        
                        // Find the actual start and end dates
                        let actualStartDate = self.getActualStartDate(from: userRecords, partnerRecords: partnerRecords)
                        let actualEndDate = self.getActualEndDate(from: userRecords, partnerRecords: partnerRecords)
                        
                        completion(streakCount, actualStartDate, actualEndDate, combinedRecords, nil)
                    case .failure(let partnerError):
                        completion(nil, nil, nil, [:], partnerError)
                    }
                }
            case .failure(let userError):
                completion(nil, nil, nil, [:], userError)
            }
        }
    }
    
    
    
    func getActualStartDate(from userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Date? {
        let validDates = userRecords.keys.filter {
            (userRecords[$0]?.count ?? 0 > 0) && (partnerRecords[$0]?.count ?? 0 > 0)
        }
        return validDates.min() // The earliest date in the streak
    }

    func getActualEndDate(from userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Date? {
        let validDates = userRecords.keys.filter {
            (userRecords[$0]?.count ?? 0 > 0) && (partnerRecords[$0]?.count ?? 0 > 0)
        }
        return validDates.max() // The latest date in the streak
    }



    func calculateStreak(userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Int {
        // Create a set of all dates that are present in either user's records
        let allDates = Array(Set(userRecords.keys).union(Set(partnerRecords.keys))).sorted()

        var streakCount = 0
        var currentStreak = 0
        var lastDate: Date?

        // Iterate through dates, checking for consecutive days with records for both users
        for date in allDates {
            // Check if both users have a record for the current date
            let userHasRecord = userRecords[date] != nil
            let partnerHasRecord = partnerRecords[date] != nil

            if userHasRecord && partnerHasRecord {
                // Both users have records for this date
                if let lastDate = lastDate {
                    // Check if the current date is consecutive to the last date
                    if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!) {
                        // Continue the streak
                        currentStreak += 1
                    } else {
                        // Not consecutive, reset streak
                        currentStreak = 1
                    }
                } else {
                    // Start a new streak
                    currentStreak = 1
                }

                // Update the last valid date to the current date
                lastDate = date
            } else {
                // Break the streak if either user is missing a record for this date
                currentStreak = 0
            }

            // Update the maximum streak count
            streakCount = max(streakCount, currentStreak)
        }

        return streakCount
    }
    
    
    
    
    
    

    
    
    
    private func updatePartnerData() {
        guard let partnerData = self.partnerData else { return }
        
        self.poopData = partnerData["poop"] as? [String: Any] ?? [:]
        self.sleepData = partnerData["sleep"] as? [String: Any] ?? [:]
        self.moodData = partnerData["mood"] as? [String: Any] ?? [:]
        self.energyData = partnerData["energy"] as? [String: Any] ?? [:]

    }
}


