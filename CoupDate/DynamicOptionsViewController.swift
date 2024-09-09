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
    var lottieAnimations: [String?] = [] // Optional Lottie animation names (or nil for just text)
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
        collectionView.backgroundColor = .black
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
        collectionView.allowsMultipleSelection = true // Enable multi-selection
        // Ensure the view has a black background
        view.backgroundColor = .black
        
        // Ensure the collection view also has a black background
    }

    private func setupUI() {
        // Title label
        titleLabel.text = categoryTitle
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        
        // Close Button Setup
        closeButton.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal) // Ensure the image respects the tint
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .white // Set the button tint color to white
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
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0) // Purple shade
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
        let lottieName = lottieAnimations[indexPath.row]
        
        cell.configure(with: optionText, lottieAnimation: lottieName)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout for Dynamic Grid
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = UIScreen.main.bounds.width > 400 ? 3 : 2
        let padding: CGFloat = 16
        let totalPadding = padding * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem) // Square cells
    }
    
    
    // Handle multiple selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        selectedOptions.append(selectedOption) // Add the selected option to the list
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedOption = options[indexPath.row]
        if let index = selectedOptions.firstIndex(of: deselectedOption) {
            selectedOptions.remove(at: index) // Remove the deselected option from the list
        }
    }

    // MARK: - Save Button Action
    
    @objc private func saveSelectedOptions() {
        // Print the selected options
        print("Selected options: \(selectedOptions)")
        

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Background color for the cell
        backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        layer.cornerRadius = 10
        
        // Label for the option text
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        // Constraints for the label
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with text: String, lottieAnimation: String?) {
        // Set the text for the option
        label.text = text
        
        // If a Lottie animation is provided, configure the animation view
        if let animationName = lottieAnimation {
            if lottieView == nil {
                lottieView = LottieAnimationView(name: animationName)
                lottieView?.loopMode = .loop
                lottieView?.contentMode = .scaleAspectFit
                lottieView?.translatesAutoresizingMaskIntoConstraints = false
                addSubview(lottieView!)
                
                // Constraints for the Lottie animation
                NSLayoutConstraint.activate([
                    lottieView!.centerXAnchor.constraint(equalTo: centerXAnchor),
                    lottieView!.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                    lottieView!.widthAnchor.constraint(equalToConstant: 80),
                    lottieView!.heightAnchor.constraint(equalToConstant: 80)
                ])
            }
            lottieView?.play()
        } else {
            // If no animation, remove the lottie view if present
            lottieView?.removeFromSuperview()
            lottieView = nil
        }
    }
    
    // Highlight the cell when selected
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0) : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }
}
