//
//  ViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    // Hardcoded user IDs for testing
    let myUserID = "myUserID123"  // Replace with your actual userID
    let gfUserID = "gfUserID456"  // Replace with your girlfriend's actual userID

    // Initialize Firestore
    let db = Firestore.firestore()
    
    
    // UI Components
    let poopStatusLabel = UILabel()
    let poopDetailLabel = UILabel()
    let sleepStatusLabel = UILabel()
    let sleepDetailLabel = UILabel()
    let refreshButton = UIButton(type: .system)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
              title = "💑 Coudate"
              
              setupUI()
              loadPartnerData()
        
       // addActivity(for: myUserID, date: "2024-09-01", poopStatus: "YES", sleepStatus: "B", poopDetails: "All good!", sleepDetails: "Slept well.")
        
        
    }
    
    
    
    func setupUI() {
        // Poop Status Label
        poopStatusLabel.text = "💩 Linda’s Poop Status Today: YES"
        poopStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        poopStatusLabel.textAlignment = .center
        poopStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(poopStatusLabel)
        
        // Poop Detail Label
        poopDetailLabel.text = "Smooth like butter."
        poopDetailLabel.font = UIFont.systemFont(ofSize: 16)
        poopDetailLabel.textAlignment = .center
        poopDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(poopDetailLabel)
        
        // Sleep Status Label
        sleepStatusLabel.text = "😴 Linda’s Sleep: 6-8 hrs 🥳"
        sleepStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        sleepStatusLabel.textAlignment = .center
        sleepStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sleepStatusLabel)
        
        // Sleep Detail Label
        sleepDetailLabel.text = "Dreaming of you... 💕"
        sleepDetailLabel.font = UIFont.systemFont(ofSize: 16)
        sleepDetailLabel.textAlignment = .center
        sleepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sleepDetailLabel)
        
        // Refresh Button
        refreshButton.setTitle("Send a High-Five! ✋", for: .normal)
        refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        view.addSubview(refreshButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            poopStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            poopStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poopStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            poopDetailLabel.topAnchor.constraint(equalTo: poopStatusLabel.bottomAnchor, constant: 10),
            poopDetailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poopDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            sleepStatusLabel.topAnchor.constraint(equalTo: poopDetailLabel.bottomAnchor, constant: 30),
            sleepStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sleepStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            sleepDetailLabel.topAnchor.constraint(equalTo: sleepStatusLabel.bottomAnchor, constant: 10),
            sleepDetailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sleepDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshButton.topAnchor.constraint(equalTo: sleepDetailLabel.bottomAnchor, constant: 40),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func refreshTapped() {
        // Placeholder for sending high-five or refreshing data
        let alert = UIAlertController(title: "High-Five Sent!", message: "Linda will receive a notification. 😊", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func loadPartnerData() {
        // Placeholder for loading partner data from Firebase
        // Update the labels with real data here
    }
    
    
    func addActivity(for userID: String, date: String, poopStatus: String, sleepStatus: String, poopDetails: String?, sleepDetails: String?) {
        let activitiesRef = db.collection("users").document(userID).collection("activities").document(date)
        
        activitiesRef.setData([
            "poopStatus": poopStatus,
            "poopDetails": poopDetails ?? "",
            "sleepStatus": sleepStatus,
            "sleepDetails": sleepDetails ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error adding activity: \(error)")
            } else {
                print("Activity added successfully")
            }
        }
    }
    
    
    func fetchActivities(for userID: String) {
        let activitiesRef = db.collection("users").document(userID).collection("activities")
        
        activitiesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching activities: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print("Date: \(document.documentID), Data: \(data)")
                }
            }
        }
    }


}

