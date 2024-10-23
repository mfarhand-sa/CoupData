//
//  CDThoughtViewController.swift
//  CoupDate
//
//  Created by mo on 2024-10-23.
//

import Foundation
import UIKit
import KRProgressHUD
class ThoughtViewController: UIViewController, UITextViewDelegate {

    private let maxCharacterLimit = 200
    private var  payLoadText  = ""
    // Back Button
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal) // Ensure the image respects the tint
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .CDText // Set the button tint color to white        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    // Large Placeholder Label
    private let mainPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "What's on your mind?"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold) // Bigger font
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Small Description Label
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Share any thought, feeling, or idea - big or small. Be brief, but honest. There's no right or wrong here."
        label.font = UIFont.systemFont(ofSize: 16, weight: .light) // Smaller font
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // UITextView for user input
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 28) // Cursor size matches the placeholder font
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear // No borders, clear background
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0) // Adjust the top inset to align the cursor
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false // Ensure the textView does not scroll
        return textView
    }()

    
    // Placeholder Top Constraint for animation
    private var mainPlaceholderTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        textView.delegate = self
        
        view.addSubview(backButton)
        view.addSubview(mainPlaceholder)
        view.addSubview(descriptionPlaceholder)
        view.addSubview(textView)
        
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder() // Show keyboard when the page opens
    }
    
    // Set up constraints for the views
    private func setupConstraints() {
        // Back Button at the top-left
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 25), // Adjust size as needed
            backButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        // Placeholder (before animation)
        mainPlaceholderTopConstraint = mainPlaceholder.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 60)

        NSLayoutConstraint.activate([
            // Main Placeholder (large text)
            mainPlaceholderTopConstraint, // Initially place it with more top padding
            mainPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Description Placeholder (small text at bottom)
            descriptionPlaceholder.topAnchor.constraint(equalTo: mainPlaceholder.bottomAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // TextView (user input)
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150), // Fixed position to stop moving up
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            // Reset to initial state when textView is empty
            resetPlaceholderPosition()
        } else {
            // Start animation when user begins typing
            animatePlaceholderUp()
        }
    }
    
    // MARK: - Animations

    private func animatePlaceholderUp() {
        // Only animate if the placeholder is still in the initial position
        if mainPlaceholderTopConstraint.constant == 60 {
            descriptionPlaceholder.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.mainPlaceholder.font = UIFont.systemFont(ofSize: 18, weight: .medium) // Smaller font
                self.mainPlaceholderTopConstraint.constant = 20 // Move it up, keeping proper padding from the back button
                self.view.layoutIfNeeded()
            }
        }
    }

    private func resetPlaceholderPosition() {
        descriptionPlaceholder.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.mainPlaceholder.font = UIFont.systemFont(ofSize: 28, weight: .bold) // Original large font
            self.mainPlaceholderTopConstraint.constant = 60 // Reset to original position
            self.view.layoutIfNeeded()
        }
    }
    
    // Back button action
    @objc private func didTapBackButton() {
        // Action when back button is tapped, e.g., dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            self.payLoadText = textView.text
            triggerReturnKeyAction() // Your custom method
            return false // Prevent the return key from adding a newline
        }
        
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // Limit to 200 characters
        return newText.count <= 200
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.becomeFirstResponder()
    }
    
    private func triggerReturnKeyAction() {
        
        KRProgressHUD.show(withMessage: "Please wait...")
        
        print("Return key pressed.")
        
        
        
        Haptic.play()
        
        FirebaseManager.shared.saveDailyRecord(for: UserManager.shared.currentUserID!, date: Date(), category: "Thoughts", statuses: [self.payLoadText], details: "") { result in
            // Handle result
        }
        
        
        
        // Add your logic here
        
        let prompt = """
        Reframe the following text (my current thoughts) with a positive vibe, and extract these fields based on my text (one word): 
        - Personality
        - Desire
        - Bias
        - Emotions

        Text: \(self.payLoadText)
        """

        OpenAIManager.shared.fetchOpenAIResponse(prompt: prompt) { result in
            DispatchQueue.main.async {
                if let result = result {
                    KRProgressHUD.dismiss()
                    self.showResultInAlertController(result: result, viewController: self)
                } else {
                    print("Failed to get response")
                    KRProgressHUD.dismiss()

                }
            }
        }

        
    }
    
    
    func showResultInAlertController(result: String, viewController: UIViewController) {
        // Define colors for each field
        let personalityColor = UIColor.red
        let desireColor = UIColor.blue
        let biasColor = UIColor.green
        let emotionsColor = UIColor.purple

        // Define the text to search for
        let fields = ["Personality", "Desire", "Bias", "Emotions"]
        let colors = [personalityColor, desireColor, biasColor, emotionsColor]

        // Create an NSMutableAttributedString from the result
        let attributedString = NSMutableAttributedString(string: result)

        // Apply colors to each field
        for (index, field) in fields.enumerated() {
            if let range = result.range(of: field) {
                let nsRange = NSRange(range, in: result)
                attributedString.addAttribute(.foregroundColor, value: colors[index], range: nsRange)
            }
        }

        // Create an alert controller
        let alertController = UIAlertController(title: "Insights", message: nil, preferredStyle: .alert)

        // Add a "Close" action button
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

        // Set the attributed string as the message
        alertController.setValue(attributedString, forKey: "attributedMessage")

        // Present the alert controller
        viewController.present(alertController, animated: true, completion: nil)
    }


}


