import Combine
import Foundation
import UIKit

class PartnerViewModel: ObservableObject {
    @Published var poopData: [String: Any]?
    @Published var sleepData: [String: Any]?
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
                
                // Check if user profile is incomplete
                if data["firstNameeee"] == nil {
                    self.userInfoRequired = true
                    self.isLoading = false
                    return
                } else {
                    self.userInfoRequired = false
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
                
            case .failure(let error):
                self.errorMessage = "Error loading partner data: \(error.localizedDescription)"
                print("Error loading partner data: \(error)")
            }
        }
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
