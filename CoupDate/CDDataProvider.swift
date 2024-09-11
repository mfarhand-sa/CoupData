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

    var poopData: [String: Any]?
    var sleepData: [String: Any]?

    private init() {
    }
    
    /// Reset method will reset all the properties and it'll be used after logout or delete account
    public func reset() {}
    
    
    func generatePairingLink(forUserId userId: String) -> URL? {
        return URL(string: "https://mytripper.app/pair?partnerUserId=\(userId)")
    }
    
    
}
