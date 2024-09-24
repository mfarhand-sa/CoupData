//
//  CDLoadingViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-02.
//

import Foundation
import UIKit
import Lottie
import Combine
import FirebaseAuth


class CDLoadingViewController : UIViewController {
    
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Array of messages
    let messages = [
        "Take a deep breath and connect with your partner today.",
        "Small moments of care can make a big difference.",
        "Your well-being journey starts with understanding and support."
    ]
    
    
    
    
    private func showRegistrationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let registrationVC = storyboard.instantiateViewController(withIdentifier: "CDUserRegistrationViewController") as! CDUserRegistrationViewController
        registrationVC.status = .fullName
        self.updateRootViewController(to: registrationVC)
    }
    
    
    private func checkAuthenticationAndLoadPartnerData() {
        
        CDDataProvider.shared.loadMyDataAndThenPartnerData { success, userNeedMoreData, userData, partnerData, errorInfo in
            
            guard success else {
                print("Oops, something went wrong")
                return
            }
            
            if userNeedMoreData {
                self.showRegistrationScreen()
            } else if userData || partnerData {
                
             
                FirebaseManager.shared.fetchMoods(for: CDDataProvider.shared.gender!) { Result in
                    print(Result);
                    CDDataProvider.shared.moods = Result
                }
                if let partnerID = CDDataProvider.shared.partnerID, !partnerID.isEmpty {
                    
                    CDDataProvider.shared.loadAllUserAndPartnerData(userID: UserManager.shared.currentUserID!, partnerID: UserManager.shared.partnerUserID!) { streakCount, startDate, endDate, dailyRecords, error in
                        if let streakCount = streakCount, let startDate = startDate, let endDate = endDate {
                            
                            CDDataProvider.shared.dailyRecords = dailyRecords
                            CDDataProvider.shared.streak = streakCount
                            CDDataProvider.shared.startDate = startDate
                            CDDataProvider.shared.endDate = endDate
                            

                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                self.navigateToMainScreen()
                            })
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                self.navigateToMainScreen()
                            })
                            
                        }
                        
                        
                    }

                    
                } else {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.navigateToMainScreen()
                    })
                }
                
                
            } else {
                // Show the pairing screen if needed
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if hasUserLoggedIn() == false {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.navigateToLoginScreen()
            }
            
        } else {
            
            checkAuthenticationAndLoadPartnerData()
        }
        
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor(named: "CDBackground")
        self.copyrightLabel.textColor = .CDText
        self.floatingLabel.textColor = .CDText
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.0
        animationView.backgroundColor = UIColor(named: "CDBackground")
        animationView!.play()
        showMessagesWithAnimation()
        let year = Calendar.current.component(.year, from: Date())
        self.copyrightLabel.text = "\(year) © LEOIO Inc."
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
                floatingLabel.text = currentMessage
                
                // Apply animation to the label
                applyFloatingAnimation(to: floatingLabel) {
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
    
    
    
    
    
    // Check the current user's authentication state
    func hasUserLoggedIn()->Bool {
        if let user = Auth.auth().currentUser,UserDefaults.standard.value(forKey: "loggedIn") != nil {
            print("User is already signed in: \(user.uid)")
            return true
        } else {
            print("No user is signed in.")
            return false
        }
    }
    
    // Navigate to the main screen of your app
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? CDTabbarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }
//        tabBarVC.viewModel = self.viewModel
        updateRootViewController(to: tabBarVC)
    }
    
    // Navigate to the login screen
    func navigateToLoginScreen() {
        let loginVC = CoupleLoginViewController()
        updateRootViewController(to: loginVC)
    }
}




