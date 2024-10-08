//
//  DynamicOptionsViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-07.
//

import UIKit
import Lottie


class DynamicOptionsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // Dynamic properties to set title, description, and options
    var categoryTitle: String = "Vibe Check"
    var descriptionText: String = "How are you feeling today?"
    var options: [String] = [] // Dynamic list of options
    var selectedOptions: [String] = [] // Track selected options
    var category: String = ""

    
    // UI Elements
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.backgroundColor = UIColor(named: "CDBackground")
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
        collectionView.allowsMultipleSelection = true // Enable multi-selection
        // Ensure the view has a black background
        view.backgroundColor = UIColor(named: "CDBackground")
        
        updateSaveButtonState()
        
        // Ensure the collection view also has a black background
    }

    
    private func updateSaveButtonState() {
        saveButton.isEnabled = !selectedOptions.isEmpty
        saveButton.backgroundColor = selectedOptions.isEmpty ? .lightGray : .accent // Optional: change color when disabled
    }
    
    
    private func setupUI() {
        // Title label
        titleLabel.text = categoryTitle
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 24)
        titleLabel.textColor = .CDText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        
        // Close Button Setup
        closeButton.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal) // Ensure the image respects the tint
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .CDText // Set the button tint color to white
        view.addSubview(closeButton)

        // Layout constraints for close button (besides the greeting label)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 25), // Adjust size as needed
            closeButton.heightAnchor.constraint(equalToConstant: 25)
        ])

        // Description label
        descriptionLabel.text = descriptionText
        descriptionLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        descriptionLabel.textColor = .CDText
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .accent
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveSelectedOptions), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Ensure the save button has padding
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Adjust collection view in relation to save button and description
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 70, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add collection view constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16)
        ])
    }

    // MARK: - UICollectionView DataSource & Delegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
        let optionText = options[indexPath.row]
        cell.configure(with: optionText) // No need to pass the Lottie animation separately
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout for Dynamic Grid
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = UIScreen.main.bounds.width > 400 ? 3 : 2
        let padding: CGFloat = 16
        let totalPadding = padding * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / itemsPerRow

        // Return the same size for each item (height will be based on content)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    // Handle multiple selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Haptic.play()
        let selectedOption = options[indexPath.row]
        selectedOptions.append(selectedOption) // Add the selected option to the list
        updateSaveButtonState() // Update button state after selecting an option
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedOption = options[indexPath.row]
        if let index = selectedOptions.firstIndex(of: deselectedOption) {
            selectedOptions.remove(at: index) // Remove the deselected option from the list
        }
        updateSaveButtonState() // Update button state after deselecting an option
    }

    // MARK: - Save Button Action
    
    @objc private func saveSelectedOptions() {
        // Print the selected options
        Haptic.play()
        print("Selected options: \(selectedOptions)")
        CDTracker.trackEvent(eventName: "Check-in", params: [self.category : selectedOptions])
        CDNotificationManager.shared.scheduleNotifications(userName: CDDataProvider.shared.name, moods: selectedOptions)
        FirebaseManager.shared.saveDailyRecord(for: UserManager.shared.currentUserID!, date: Date(), category: self.category, statuses: selectedOptions, details: "") { result in
            // Handle result
        }
        
        
        self.dismiss(animated: true)
    }
    
    
    @objc private func closeView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Custom Option Cell

class OptionCell: UICollectionViewCell {
    
    private let label = UILabel()
    private var lottieView: LottieAnimationView?
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Set up the border for the cell
        layer.borderWidth = 0.6
        layer.cornerRadius = 10
        layer.borderColor = UIColor.CDText.cgColor // Default border color

        // Configure the stack view for vertical alignment of Lottie and label
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        // Add Lottie animation view and label to the stack view
        label.textAlignment = .center
        stackView.addArrangedSubview(UIView()) // Add a placeholder initially
        stackView.addArrangedSubview(label)

        // Set constraints for the stack view to center it vertically and horizontally
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    func configure(with text: String) {
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        // Remove previous Lottie view if it exists
        if let lottieView = lottieView {
            stackView.removeArrangedSubview(lottieView)
            lottieView.removeFromSuperview()
        }

        // Try to load the Lottie animation with the same name as the text
        if let animation = LottieAnimation.named(text) {
            lottieView = LottieAnimationView(animation: animation)
            lottieView?.loopMode = .loop
            lottieView?.contentMode = .scaleAspectFit
            lottieView?.translatesAutoresizingMaskIntoConstraints = false

            // Add the Lottie view to the stack view
            stackView.insertArrangedSubview(lottieView!, at: 0)

            // Set size for Lottie animation
            NSLayoutConstraint.activate([
                lottieView!.widthAnchor.constraint(equalToConstant: 50),
                lottieView!.heightAnchor.constraint(equalToConstant: 50)
            ])
            lottieView?.play()
        }
    }

    // Highlight the cell when selected
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColor.accent.cgColor : UIColor.CDText.cgColor
            self.layer.borderWidth = isSelected ? 1 : 0.6
        }
    }
}



