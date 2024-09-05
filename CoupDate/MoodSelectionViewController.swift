import UIKit
import Firebase


class MoodSelectionViewController: UIViewController {

    private let moodSlider = MoodSlider()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureSaveButton() // Configuring the save button
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground // Supports both light and dark modes
        
        // Configure and add the mood slider
        moodSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(moodSlider)
        
        // Set constraints for the mood slider
        NSLayoutConstraint.activate([
            moodSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodSlider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 350), // Increased constant to add more space from the face to the slider
            moodSlider.widthAnchor.constraint(equalToConstant: 300),
            moodSlider.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add the save button to the view
        view.addSubview(saveButton)
        
        // Set constraints for the save button
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80), // Position save button 80 points above the bottom
            saveButton.heightAnchor.constraint(equalToConstant: 50) // Ensure button height is more prominent
        ])
    }

    private func configureSaveButton() {
        saveButton.setTitle("Save Data", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        saveButton.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0) // Purple shade suitable for both light and dark mode
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10 // Reduced corner radius for a sleeker look
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowRadius = 4
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveMood), for: .touchUpInside)
    }

    @objc private func saveMood() {
        // Action to save the mood selection
        let moodValue = moodSlider.value
        print("Mood saved with value: \(moodValue)")

        // Convert moodValue to String to use as a document ID
        let moodValueString = String(moodValue)

        // TODO: Implement actual save logic (e.g., save to database, send to server, etc.)
        
        let userId = UserManager.shared.currentUserID // Replace with the actual user ID
        guard let userId = userId else {return}
        let db = Firestore.firestore()

        // Use a subcollection for tokens under each user
        db.collection("users").document(userId).collection("moodStatus").document(moodValueString).setData([
            "mood": moodValue  // Optionally store the mood value in the document
        ]) { error in
            if let error = error {
                print("Error saving mood to Firestore: \(error)")
            } else {
                print("Mood saved successfully to Firestore.")
            }
        }
    }

}
