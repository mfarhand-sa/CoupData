import Combine
import Foundation
import UIKit

class PartnerViewModel: ObservableObject {
    @Published var poopData: [String: Any]?
    @Published var sleepData: [String: Any]?
    @Published var moodData: [String: Any]?
    @Published var isLoading: Bool = true
    @Published var userInfoRequired: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // Method to load your data and then fetch partner data
    func loadMyDataAndThenPartnerData() {
        self.isLoading = true
        
        FirebaseManager.shared.fetchUserProfile(userID: UserManager.shared.currentUserID!) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                print("User data: \(data)")
                
                if let partnerID = data["partnerUserId"] as? String {
                    CDDataProvider.shared.partnerID = partnerID
                    UserManager.shared.partnerUserID = partnerID
                }
                
                if let firstName = data["firstName"] as? String, !firstName.isEmpty || CDDataProvider.shared.name != nil {
                    CDDataProvider.shared.name = firstName
                }
                
                if let gender = data["gender"] as? String {
                    CDDataProvider.shared.gender = gender
                }
                
                
                // Check if user profile is incomplete
                if (data["firstName"] == nil || data["birthday"] == nil || data["partnerUserId"] == nil || data["gender"] == nil ) {
                    self.userInfoRequired = true
                    self.isLoading = false
                    return
                } else {
                    self.userInfoRequired = false
                    // Save firstName in CDDataProvider
                    CDDataProvider.shared.name = data["firstName"] as? String
                }

                // Extract partner ID
                if let partnerID = data["partnerUserId"] as? String {
                    CDDataProvider.shared.partnerID = partnerID
                    UserManager.shared.partnerUserID = partnerID
                    
                    // Load partner data after fetching partner ID
                    self.loadPartnerData(partnerID: partnerID)
                } else {
                    self.errorMessage = "Partner ID not found in user data."
                    self.isLoading = false
                }

            case .failure(let error):
                self.errorMessage = "Error loading user data: \(error.localizedDescription)"
                print("Error loading user data: \(error)")
                self.isLoading = false
            }
        }
    }

    // Method to load partner data using partner ID
    func loadPartnerData(partnerID: String) {
        self.isLoading = true
        FirebaseManager.shared.loadDailyRecord(for: partnerID, date: Date()) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let data):
                // Ensure poopData and sleepData are updated
                if let poopData = data["poop"] as? [String: Any] {
                    self.poopData = poopData
                } else {
                    self.poopData = [:] // Set an empty value to trigger Combine
                }
                
                if let sleepData = data["sleep"] as? [String: Any] {
                    self.sleepData = sleepData
                } else {
                    self.sleepData = [:] // Set an empty value to trigger Combine
                }
                
                if let moodData = data["mood"] as? [String: Any] {
                    self.moodData = moodData
                } else {
                    self.moodData = [:] // Set an empty value to trigger Combine
                }
            case .failure(let error):
                self.errorMessage = "Error loading partner data: \(error.localizedDescription)"
                print("Error loading partner data: \(error)")
            }
        }
    }
    
    
    func loadUserAndPartnerData(userID: String, partnerID: String, daysToCheck: Int = 30, completion: @escaping (Int?, Date?, Date?, Error?) -> Void) {
        self.isLoading = true

        let endDate = Date() // Today
        let startDate = Calendar.current.date(byAdding: .day, value: -daysToCheck, to: endDate)!

        FirebaseManager.shared.streakRecords(for: userID, from: startDate, to: endDate) { [weak self] userResult in
            guard let self = self else { return }

            FirebaseManager.shared.streakRecords(for: partnerID, from: startDate, to: endDate) { [weak self] partnerResult in
                guard let self = self else { return }
                self.isLoading = false

                switch (userResult, partnerResult) {
                case (.success(let userRecords), .success(let partnerRecords)):
                    // The original streak calculation logic remains unchanged
                    let streakCount = self.calculateStreak(userRecords: userRecords, partnerRecords: partnerRecords)
                    
                    // Find the actual start and end dates based on the streak records
                    let actualStartDate = self.getActualStartDate(from: userRecords, partnerRecords: partnerRecords)
                    let actualEndDate = self.getActualEndDate(from: userRecords, partnerRecords: partnerRecords)

                    // Return the correct start and end dates along with the streak count
                    completion(streakCount, actualStartDate, actualEndDate, nil)
                case (.failure(let userError), _):
                    completion(nil, nil, nil, userError) // Handle user error
                case (_, .failure(let partnerError)):
                    completion(nil, nil, nil, partnerError) // Handle partner error
                }
            }
        }
    }

    func getActualStartDate(from userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Date? {
        let validDates = userRecords.keys.filter { userRecords[$0] == true && partnerRecords[$0] == true }
        return validDates.min() // The earliest date in the streak
    }
    
    func getActualEndDate(from userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Date? {
        let validDates = userRecords.keys.filter { userRecords[$0] == true && partnerRecords[$0] == true }
        return validDates.max() // The latest date in the streak
    }

    
    
    func calculateStreak(userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Int {
        // Sort the records by date in descending order (most recent first)
        let sortedUserRecords = userRecords.keys.sorted(by: >)
        let sortedPartnerRecords = partnerRecords.keys.sorted(by: >)

        var streakCount = 0
        var lastValidDate: Date?

        // Get today's date
        let today = Calendar.current.startOfDay(for: Date())
        
        // Flag to track if we skip today's check
        var skipToday = true

        for date in sortedUserRecords {
            // Skip today if not both users have checked in today
            if Calendar.current.isDate(date, inSameDayAs: today) {
                if userRecords[date] != true || partnerRecords[date] != true {
                    continue
                }
            }

            // Check if both users have records for this date
            if let userRecordExists = userRecords[date], let partnerRecordExists = partnerRecords[date], userRecordExists && partnerRecordExists {
                if let lastDate = lastValidDate {
                    // Check if this record is exactly one day after the last valid record
                    if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: lastDate)!) {
                        streakCount += 1
                        lastValidDate = date // Continue the streak
                    } else {
                        // Streak is broken, stop here
                        break
                    }
                } else {
                    // First valid record, start the streak
                    streakCount += 1
                    lastValidDate = date
                }
            } else {
                // Break the loop if we don't have a match for both users' records (but ignore today)
                if !Calendar.current.isDate(date, inSameDayAs: today) {
                    break
                }
            }
        }

        return streakCount
    }


    

    func updateRootViewController(to viewController: UIViewController) {
        // Ensure we are running on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateRootViewController(to: viewController)
            }
            return
        }

        if let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let window = windowScene.windows.first {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        } else {
            print("No active window scene found.")
        }
    }
}
