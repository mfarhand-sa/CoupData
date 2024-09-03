//
//  CDViewModel.swift
//  CoupDate
//
//  Created by mo on 2024-09-02.
//

import Foundation

import Combine

class PartnerViewModel: ObservableObject {
    @Published var poopData: [String: Any]?
    @Published var sleepData: [String: Any]?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadPartnerData() {
        let partnerUserId = UserManager.shared.partnerUserID // Replace with actual partner user ID
        let currentDate = Date()

        self.isLoading = true

        FirebaseManager.shared.loadDailyRecord(for: partnerUserId, date: currentDate) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let data):
                if let poopData = data["poop"] as? [String: Any] {
                    self.poopData = poopData
                }
                
                if let sleepData = data["sleep"] as? [String: Any] {
                    self.sleepData = sleepData
                }
                
            case .failure(let error):
                self.errorMessage = "Error loading partner data: \(error.localizedDescription)"
                print("Error loading partner data: \(error)")
            }
        }
    }
}
