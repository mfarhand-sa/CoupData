//
//  CDPairingViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-05.
//

import UIKit
import Lottie


class CDPairingViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    public var partnerUserId: String!
    let messages = [
        "We are adding your partner to you account",
        "We are adding your partner to you account",
        "We are adding your partner to you account"
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
        
        
        showMessagesWithAnimation()

        FirebaseManager.shared.savePartnerUserId(partnerUserId) { result in
            
            switch result {
            case .success(let isSaved):
                if isSaved {
                    print("Partner user ID saved successfully.")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        
                        CustomAlerts.displayNotification(title: "", message: "Partner user ID saved successfully.", view: self.view,fromBottom: true)
                        self.dismiss(animated: true)
                    }
                    
 
                    
                } else {
                    print("Partner user ID was not saved successfully.")
                }
            case .failure(let error):
                print("Failed to save partner user ID with error: \(error.localizedDescription)")
            }
            
        }

    }

    
    
    func showMessagesWithAnimation() {
        // Get two random messages from the array
        let randomMessages = messages.shuffled().prefix(2)

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
    

}
