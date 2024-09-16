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

    
    
    // Stored data properties
    var userData: [String: Any]?
    var partnerData: [String: Any]?
    
    
    var poopData: [String: Any]?
    var sleepData: [String: Any]?
    var moodData: [String: Any]?

    
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
    

    
    
    
    private func updatePartnerData() {
        guard let partnerData = self.partnerData else { return }
        
        self.poopData = partnerData["poop"] as? [String: Any] ?? [:]
        self.sleepData = partnerData["sleep"] as? [String: Any] ?? [:]
        self.moodData = partnerData["mood"] as? [String: Any] ?? [:]
    }
}


