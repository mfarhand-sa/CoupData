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
    
    
    let messages = [
        "We are adding your partner to you account",
        "We are adding your partner to you account",
        "We are adding your partner to you account"
    ]
    
    let messagesInvitation = [
        "We are generating the invitation for your partner",
        "We are generating the invitation for your partner",
        "We are generating the invitation for your partner"
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        animationView!.animationSpeed = 1.0
        
        // 6. Play animation
        
        animationView!.play()
        
        
        
        if mode == .pair {
            
            guard let token = self.partnerUserId else {return}
            FirebaseManager.shared.pairUsersWithToken(token: token) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Partner user ID saved successfully.")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            
                            CustomAlerts.displayNotification(title: "", message: "Partner user ID saved successfully.", view: self.view,fromBottom: true)
                            NotificationCenter.default.post(name: NSNotification.Name("CDPairingDismissed"), object: nil)
                            
                            
                            self.dismiss(animated: true) {}
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
            
            
            generateInvitationLink()
            
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMessagesWithAnimation()
        
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
    
    
    @objc func generateInvitationLink() {
        // Call the Firebase function to generate the invitation link
        
        guard let currentUserID = UserManager.shared.currentUserID else {return}
        let data: [String: Any] = ["partnerUserId": currentUserID ]
        
        functions.httpsCallable("generateInvitationLink").call(data) { result, error in
            if let error = error {
                print("Error generating invitation link: \(error.localizedDescription)")
                CustomAlerts.displayNotification(title: "", message: "Error generating invitation link: \(error.localizedDescription)", view: self.view)
                self.dismiss(animated: true)
                return
            }
            
            if let resultData = result?.data as? [String: Any] {
                // Handle the invitation response
                self.handleInvitationResponse(response: resultData)
            }
        }
    }
    
    
    
    
    func handleInvitationResponse(response: [String: Any]) {
        if let qrCodeDataURL = response["qrCodeBase64"] as? String,
           let qrCodeImage = convertBase64ToImage(base64String: qrCodeDataURL) {
            
            // Generate the invitation image with the QR code
            if let senderName = CDDataProvider.shared.name {
                let invitationImage = generateInvitationImage(senderName: senderName, qrCodeImage: qrCodeImage)
                
                if let qrImage = invitationImage, let url = response["link"] as? String {
                    print("Generated invitation link: \(url)")

                    var items: [Any] = []  // Declare as [Any] to hold both UIImage and String
                    if let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        items.append(encodedURL)
                    } else {
                        print("Invalid URL: \(url)")
                    }
                    items.append(qrImage)
                    
                    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                        if completed {
                            print("The sharing was successful.")
                            self.dismiss(animated: true)
                            if let activityType = activityType {
                                print("Activity type: \(activityType.rawValue)")
                            }
                        } else {
                            print("The sharing was canceled.")
                            self.dismiss(animated: true)
                        }
                        
                        if let error = error {
                            print("An error occurred: \(error.localizedDescription)")
                            self.dismiss(animated: true)
                        }
                    }
                    
                    // Check if the selected activity is AirDrop and only share the image
                    activityVC.activityItemsConfiguration = [
                        UIActivity.ActivityType.airDrop: [url], // Share only the image via AirDrop
                        UIActivity.ActivityType.message: [qrImage, url], // Share both for other apps
                        UIActivity.ActivityType.mail: [qrImage, url]
                    ] as? UIActivityItemsConfigurationReading
                    
                    self.present(activityVC, animated: true)


                    
                   
                    
                } else {
                    CustomAlerts.displayNotification(title: "", message: "Something went wrong, try again later - Invalid QR code", view: self.view)
                    self.dismiss(animated: true)
                }
            }
        } else {
            CustomAlerts.displayNotification(title: "", message: "Something went wrong, try again later - Invalid response from server", view: self.view)
            self.dismiss(animated: true)
        }
    }

    
    
    
//    
//    func handleInvitationResponse(response: [String: Any]) {
//        if let qrCodeDataURL = response["qrCodeBase64"] as? String,
//           let qrCodeImage = convertBase64ToImage(base64String: qrCodeDataURL) {
//            
//            // Generate the invitation image with the QR code
//            if let senderName = CDDataProvider.shared.name {
//                let invitationImage = generateInvitationImage(senderName: senderName, qrCodeImage: qrCodeImage)
//                // Display or share the invitationImage (e.g., save to gallery, share via social media, etc.)
//                
//                
//                if let qrImage = invitationImage, let url = response["link"] as? String {
//                    print("Generated invitation link: \(url)")
//                    // Show share sheet for the user to send the invitation link
//                    
//                    let activityVC = UIActivityViewController(activityItems: [url,qrImage], applicationActivities: nil)
//                    
//                    
//                    
//                    activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
//                        if completed {
//                            print("The sharing was successful.")
//                            self.dismiss(animated: true)
//                            if let activityType = activityType {
//                                print("Activity type: \(activityType.rawValue)")
//                            }
//                        } else {
//                            print("The sharing was canceled.")
//                            self.dismiss(animated: true)
//                            
//                        }
//                        
//                        if let error = error {
//                            print("An error occurred: \(error.localizedDescription)")
//                            self.dismiss(animated: true)
//                            
//                        }
//                    }
//                    
//                    self.present(activityVC, animated: true)
//                    
//                } else {
//                    
//                    CustomAlerts.displayNotification(title: "", message: "Something went wrong try again later - Invalid QR code", view: self.view)
//                    self.dismiss(animated: true)
//                    
//                }
//                
//                
//                
//            }
//        } else {
//            
//            CustomAlerts.displayNotification(title: "", message: "Something went wrong try again later - Invalid response from server", view: self.view)
//            self.dismiss(animated: true)
//        }
//    }
    
    
    // Convert base64 string to UIImage
    func convertBase64ToImage(base64String: String) -> UIImage? {
        // Remove the data:image/png;base64, prefix if it exists
        var cleanBase64String = base64String
        if base64String.hasPrefix("data:image/png;base64,") {
            cleanBase64String = base64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
        }
        
        // Convert the base64 string to Data
        guard let imageData = Data(base64Encoded: cleanBase64String, options: .ignoreUnknownCharacters) else {
            print("Error: Unable to decode base64 string")
            return nil
        }
        
        // Create and return the UIImage from the Data
        let image = UIImage(data: imageData)
        return image
    }
    
    
    // Generate the final invitation image with QR code
    func generateInvitationImage(senderName: String, qrCodeImage: UIImage) -> UIImage? {
        let invitationText = "\(senderName) has requested to add you as a partner in CoupDate"
        
        let imageSize = CGSize(width: 300, height: 500)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        
        // Draw background
        let backgroundColor = UIColor.systemPink
        backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: imageSize))
        
        // Draw text
        let textFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let textColor = UIColor.white
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        
        let textRect = CGRect(x: 20, y: 50, width: imageSize.width - 40, height: 100)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor,
            .paragraphStyle: textStyle
        ]
        invitationText.draw(in: textRect, withAttributes: textAttributes)
        
        // Draw the QR code
        let qrCodeRect = CGRect(x: (imageSize.width - 200) / 2, y: 200, width: 200, height: 200)
        qrCodeImage.draw(in: qrCodeRect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
}
