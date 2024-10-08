//
//  PartnerCodeViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-10.
//

import Foundation
import UIKit
import Firebase




class PartnerCodeViewController: UIViewController,UIGestureRecognizerDelegate,PinCodeTextFieldDelegate {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var partnerCodeTextField: PinCodeTextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nextButton: CDButton!
    @IBOutlet weak var shareButton: CDButton!
    private let closeButton = UIButton(type: .custom)
    public var shouldShowCloseButton = false

    var partnerCode: String!
    var viewModel : PartnerViewModel!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.partnerCodeTextField.textColor = .CDText
        self.partnerCodeTextField.keyboardType = .default
        self.partnerCodeTextField.autocapitalizationType = .allCharacters
        self.partnerCodeTextField.pinCodeDelegate = self
        self.codeLabel.text = "Your code: \(self.partnerCode ?? "Unavailable!")!"
        
        closeButton.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal) // Ensure the image respects the tint
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .CDText // Set the button tint color to white
        view.addSubview(closeButton)
        self.closeButton.isHidden = !shouldShowCloseButton

        // Layout constraints for close button (besides the greeting label)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 25), // Adjust size as needed
            closeButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        
        // Create a UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        // Add the gesture recognizer to the view
        view.addGestureRecognizer(tapGesture)
        
        
        let tapGestureOnPartnerCode = UITapGestureRecognizer(target: self, action: #selector(parterCodeTap))
        tapGestureOnPartnerCode.delegate = self
        codeLabel.addGestureRecognizer(tapGestureOnPartnerCode)
        codeLabel.isUserInteractionEnabled = true // Enable interaction on the label
        
        
        
        
        generateInvitationLink(for: UserManager.shared.currentUserID!) { result in
            switch result {
            case .success(let invitationLink):
                print("Generated link: \(invitationLink)")
                DispatchQueue.main.async {
                    self.codeLabel.text = "Your code: \(self.partnerCode ?? "")"
                }
                
            case .failure(let error):
                print("Error generating link: \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePartnerJoined), name: NSNotification.Name("Partner_Joined"), object: nil)
        
        self.nextButton.setTitle("Skip", for: .normal)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("Partner_Joined"), object: nil)
    }
    
    @objc func handlePartnerJoined() {
        print("handlePartnerJoined got called")
        if shouldShowCloseButton == true {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigateToMainScreen()
        }
    }
    
    
    @objc func dismissKeyboard() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    
    
    @objc func parterCodeTap() {
        
        
        
        UIPasteboard.general.string = self.partnerCode
        CustomAlerts.displayNotification(title: "", message: "Partner code has been copied", view: self.view,fromBottom: true)
        
    }
    
    @objc private func closeView() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func shareCodeAction(_ sender: Any) {
        
        if self.partnerCode.count == 6 {
         
            self.handleInvitationResponse(response: "CoupDate://pair?token=\(partnerCode ?? "")")

        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        if self.partnerCodeTextField.text?.count == 6 {
            navigateToInvitePartner()
        } else {
            
            if self.shouldShowCloseButton == true {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigateToMainScreen()
            }
        }
    }
    
    
    
    // Function to generate the invitation link using partnerCode
    func generateInvitationLink(for userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Fetch the user's partnerCode from Firestore
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error)) // Return failure if there's an error
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let partnerCode = data["partnerCode"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or missing partner code"])))
                return
            }
            
            // Generate the invitation link
            self.partnerCode = partnerCode
            let invitationLink = "CoupDate://pair?token=\(partnerCode)"
            print("Generated Invitation Link: \(invitationLink)")
            
            completion(.success(invitationLink)) // Return the invitation link
        }
    }
    
    
    func handleInvitationResponse(response: String) {
        
        var items: [Any] = []  // Declare as [Any] to hold both UIImage and String
        guard let url =  response.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid URL: \(response)")
            return
        }
        
        items.append(url)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("The sharing was successful.")
                //                            self.dismiss(animated: true)
                
                CustomAlerts.displayNotification(title: "", message: "Your partner will join you soon", view: self.view,fromBottom: true)
                
                self.navigateToMainScreen()
                
                if let activityType = activityType {
                    print("Activity type: \(activityType.rawValue)")
                }
            } else {
                print("The sharing was canceled.")
                CustomAlerts.displayNotification(title: "", message: "You can invite your partner later", view: self.view,fromBottom: true)
                
                //                            self.dismiss(animated: true)
                self.navigateToMainScreen()
                
            }
            
        }
        
        // Check if the selected activity is AirDrop and only share the image
        activityVC.activityItemsConfiguration = [
            UIActivity.ActivityType.airDrop: [url], // Share only the image via AirDrop
            UIActivity.ActivityType.message: [url], // Share both for other apps
            UIActivity.ActivityType.mail: [url]
        ] as? UIActivityItemsConfigurationReading
        
        self.present(activityVC, animated: true)
        
    }
    
    
    
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? CDTabbarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }

        updateRootViewController(to: tabBarVC)
    }
    
    
    func navigateToInvitePartner() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Find the PartnerActivityViewController in the tab bar's view controllers
        let pairingVC = storyboard.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
        
        pairingVC.partnerUserId = self.partnerCodeTextField.text
        pairingVC.mode = .pair
        pairingVC.viewModel = self.viewModel
        
        // Set the UITabBarController as the root view controller
        updateRootViewController(to: pairingVC)
    }
    
    
    
    // Allow both gesture recognizers to work together
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func pinCodeTextFieldDidReachLimit(_ textField: PinCodeTextField) {
        print("Pin code reached the limit!")
        
        self.nextButton.setTitle("Next", for: .normal)
        // You can also access the text entered by the user if needed
        let enteredPinCode = textField.text ?? ""
        print("Entered Pin Code: \(enteredPinCode)")
        textField.resignFirstResponder()
    }
    
}


