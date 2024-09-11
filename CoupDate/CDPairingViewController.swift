//
//  CDPairingViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-05.
//

import UIKit
import Lottie
import Firebase


enum pairingMode {
    case pair
    case invitation
}

class CDPairingViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    lazy var functions = Functions.functions()
    public var mode : pairingMode = .pair
    public var partnerUserId: String!
    public var viewModel: PartnerViewModel?
    
    
    var messages = [
        "We are adding your partner to you account",
        "We are adding your partner to you account",
        "We are adding your partner to you account"
    ]
    
    var messagesInvitation = [
        "We are generating the invitation for your partner",
        "We are generating the invitation for your partner",
        "We are generating the invitation for your partner"
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupUI()
        
        if mode == .pair {
            
            guard let token = self.partnerUserId else {
                
                self.navigateToMainScreen()
                return
            }
            FirebaseManager.shared.pairUsersWithToken(token: token) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Partner user ID saved successfully.")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            
                            CustomAlerts.displayNotification(title: "", message: "Partner user ID saved successfully.", view: self.view,fromBottom: true)
                            NotificationCenter.default.post(name: NSNotification.Name("CDPairingDismissed"), object: nil)
                            
                            
                            self.navigateToMainScreen()
                        }
                        
                        
                        
                    } else {
                        print("Partner user ID was not saved successfully.")
                        CustomAlerts.displayNotification(title: "", message: "Partner user ID was not saved successfully.", view: self.view)
                        self.dismiss(animated: true)
                        
                    }
                case .failure(let error):
                    print("Failed to save partner user ID with error: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Failed to save partner user ID with error: \(error.localizedDescription)", view: self.view)
                    self.dismiss(animated: true)
                }
                
            }
            
        } else {
            
            
            generateInvitationLink(for: UserManager.shared.currentUserID!) { result in
                switch result {
                case .success(let invitationLink):
                    print("Generated link: \(invitationLink)")
                    
                case .failure(let error):
                    print("Error generating link: \(error)")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMessagesWithAnimation()
        
    }
    
    
    func setupUI() {
        self.view.backgroundColor = UIColor(named: "CDBackground")
        self.label.textColor = UIColor(named: "CDText")
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.0
        animationView!.backgroundColor = UIColor(named: "CDBackground")
        animationView!.play()
    }
    
    
    func showMessagesWithAnimation() {
        // Get two random messages from the array
        
        let randomMessages: [String]
        switch mode {
        case .pair:
            randomMessages = Array(messages.shuffled().prefix(2))
        case .invitation:
            randomMessages = Array(messagesInvitation.shuffled().prefix(2))
        default:
            randomMessages = [] // Ensure a default value is assigned
        }
        
        
        // Create an index to track which message to show
        var messageIndex = 0
        
        // Function to show the next message
        func showNextMessage() {
            if messageIndex < randomMessages.count {
                // Set the label text to the next random message
                let currentMessage = randomMessages[messageIndex]
                label.text = currentMessage
                
                // Apply animation to the label
                applyFloatingAnimation(to: label) {
                    // Increment the index to show the next message
                    messageIndex += 1
                    
                    // Schedule the next message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNextMessage()
                    }
                }
            }
        }
        
        // Start by showing the first message
        showNextMessage()
    }
    
    func applyFloatingAnimation(to label: UILabel, completion: @escaping () -> Void) {
        // Reset the label to be invisible and in its initial position
        label.alpha = 0.0
        let initialPosition = label.center
        let finalPosition = CGPoint(x: label.center.x, y: label.center.y + 10)
        
        // First, animate the label fading in and moving up
        UIView.animate(withDuration: 1.5,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            label.alpha = 1.0 // Fade in
            label.center = finalPosition // Move to final position
        }, completion: { _ in
            // After the first animation completes, animate it back down and fade out
            UIView.animate(withDuration: 1.5,
                           delay: 1.0,
                           options: [.curveEaseInOut],
                           animations: {
                label.alpha = 0.0 // Fade out
                label.center = initialPosition // Move back to initial position
            }, completion: { _ in
                completion()
            })
        })
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
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? UITabBarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }
        
        // Find the PartnerActivityViewController in the tab bar's view controllers
        if let partnerActivityVC = tabBarVC.viewControllers?.first(where: { $0 is PartnerActivityViewController }) as? PartnerActivityViewController {
            partnerActivityVC.viewModel = self.viewModel
        }
        
        // Set the UITabBarController as the root view controller
        updateRootViewController(to: tabBarVC)
    }
    
    
    
}
