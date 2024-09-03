//
//  FirebaseManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import UIKit

class DataEntryViewController: UIViewController, UITextViewDelegate {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let poopTitleLabel = UILabel()
    private let poopYesButton = UIButton(type: .system)
    private let poopNoButton = UIButton(type: .system)
    
    private let sleepTitleLabel = UILabel()
    private let sleepOptionAButton = UIButton(type: .system)
    private let sleepOptionBButton = UIButton(type: .system)
    private let sleepOptionCButton = UIButton(type: .system)
    
    private let detailsTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    
    private var selectedPoopStatus: String?
    private var selectedSleepOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Enter Data"
        
        setupUI()
        
        // Set up the tap gesture recognizer to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Set UITextView delegate to self
        detailsTextView.delegate = self
    }
    
    private func setupUI() {
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(poopTitleLabel)
        contentView.addSubview(poopYesButton)
        contentView.addSubview(poopNoButton)
        
        contentView.addSubview(sleepTitleLabel)
        contentView.addSubview(sleepOptionAButton)
        contentView.addSubview(sleepOptionBButton)
        contentView.addSubview(sleepOptionCButton)
        
        contentView.addSubview(detailsTextView)
        contentView.addSubview(saveButton)
        
        // Configure scrollView and contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Configure Poop section
        poopTitleLabel.text = "Poop Update:"
        poopTitleLabel.font = UIFont.systemFont(ofSize: 22)
        poopTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            poopTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            poopTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            poopTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        configureButton(poopYesButton, title: "YES 🍑 💩", action: #selector(poopYesTapped))
        configureButton(poopNoButton, title: "NO 🍑", action: #selector(poopNoTapped))
        
        NSLayoutConstraint.activate([
            poopYesButton.topAnchor.constraint(equalTo: poopTitleLabel.bottomAnchor, constant: 20),
            poopYesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            poopYesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            poopNoButton.topAnchor.constraint(equalTo: poopYesButton.bottomAnchor, constant: 10),
            poopNoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            poopNoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        // Configure Sleep section
        sleepTitleLabel.text = "Sleep:"
        sleepTitleLabel.font = UIFont.systemFont(ofSize: 22)
        sleepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepTitleLabel.topAnchor.constraint(equalTo: poopNoButton.bottomAnchor, constant: 30),
            sleepTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sleepTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        configureButton(sleepOptionAButton, title: "1-4 hrs 😵", action: #selector(sleepOptionATapped))
        configureButton(sleepOptionBButton, title: "6-8 hrs 🥳", action: #selector(sleepOptionBTapped))
        configureButton(sleepOptionCButton, title: "4-6 hrs 😔", action: #selector(sleepOptionCTapped))
        
        NSLayoutConstraint.activate([
            sleepOptionAButton.topAnchor.constraint(equalTo: sleepTitleLabel.bottomAnchor, constant: 20),
            sleepOptionAButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sleepOptionAButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sleepOptionBButton.topAnchor.constraint(equalTo: sleepOptionAButton.bottomAnchor, constant: 10),
            sleepOptionBButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sleepOptionBButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sleepOptionCButton.topAnchor.constraint(equalTo: sleepOptionBButton.bottomAnchor, constant: 10),
            sleepOptionCButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sleepOptionCButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        // Configure details text view
        detailsTextView.layer.cornerRadius = 8
        detailsTextView.layer.borderWidth = 1
        detailsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        detailsTextView.textColor = .label
        detailsTextView.font = UIFont.systemFont(ofSize: 16)
        detailsTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailsTextView.topAnchor.constraint(equalTo: sleepOptionCButton.bottomAnchor, constant: 20),
            detailsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Configure save button
        saveButton.setTitle("Save Data", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowRadius = 4
        saveButton.addTarget(self, action: #selector(saveData), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: detailsTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Adjust scrollView content size
        contentView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20).isActive = true
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // UITextViewDelegate method to handle return key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    private func updatePoopSelection(for button: UIButton) {
        [poopYesButton, poopNoButton].forEach {
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
        }
        
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
    }
    
    private func updateSleepSelection(for button: UIButton) {
        [sleepOptionAButton, sleepOptionBButton, sleepOptionCButton].forEach {
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
        }
        
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
    }
    
    @objc private func poopYesTapped() {
        selectedPoopStatus = "YES 🍑 💩"
        updatePoopSelection(for: poopYesButton)
    }
    
    @objc private func poopNoTapped() {
        selectedPoopStatus = "NO 🍑"
        updatePoopSelection(for: poopNoButton)
    }
    
    @objc private func sleepOptionATapped() {
        selectedSleepOption = "A: 1-4 hrs 😵"
        updateSleepSelection(for: sleepOptionAButton)
    }
    
    @objc private func sleepOptionBTapped() {
        selectedSleepOption = "6-8 hrs 🥳"
        updateSleepSelection(for: sleepOptionBButton)
    }
    
    @objc private func sleepOptionCTapped() {
        selectedSleepOption = "4-6 hrs 😔"
        updateSleepSelection(for: sleepOptionCButton)
    }
    
    @objc private func saveData() {
        // Collect data from the UI
        let poopStatus = selectedPoopStatus ?? "No Data"
        let sleepOption = selectedSleepOption ?? "No Data"
        let details = detailsTextView.text ?? ""
        
        // Ensure date is correctly set (using current date as an example)
        let currentDate = Date()
        
        // Call FirebaseManager to save the data
        FirebaseManager.shared.saveDailyRecord(for: UserManager.shared.myUserID, date: currentDate, poopStatus: poopStatus, poopDetails: details, sleepStatus: sleepOption, sleepDetails: details) { result in
            switch result {
            case .success():
                print("Data saved successfully")
                // Optionally provide user feedback or update UI here
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                print("Error saving data: \(error)")
                // Optionally handle the error and provide user feedback
            }
        }
    }
}
