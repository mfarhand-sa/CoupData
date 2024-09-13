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
    private var viewModel = PartnerViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var hasNavigated = false // Add this flag
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
        registrationVC.viewModel = self.viewModel
        self.updateRootViewController(to: registrationVC)
    }
    
    
    private func checkAuthenticationAndLoadPartnerData() {
        viewModel.$poopData
            .combineLatest(viewModel.$sleepData, viewModel.$moodData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] poopData, sleepData, moodData in
                guard let strongSelf = self else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    guard !strongSelf.hasNavigated else { return } // Only proceed if we haven't navigated

                    if let user = Auth.auth().currentUser, let _ = UserDefaults.standard.string(forKey: "loggedIn") {
                        print("User is already signed in: \(user.uid)")
                        strongSelf.navigateToMainScreen()
                        strongSelf.hasNavigated = true // Set flag here after navigating to the main screen
                    } else {
                        print("No user is signed in.")
                        strongSelf.navigateToLoginScreen()
                        strongSelf.hasNavigated = true // Set flag here after navigating to the login screen
                    }
                }
            }
            .store(in: &cancellables)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(named: "CDBackground")
        self.copyrightLabel.textColor = .CDText
        self.floatingLabel.textColor = .CDText
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        animationView!.animationSpeed = 1.0
        animationView.backgroundColor = UIColor(named: "CDBackground")
        
        // 6. Play animation
        
        animationView!.play()
        
        showMessagesWithAnimation()
        
        let year = Calendar.current.component(.year, from: Date())
        self.copyrightLabel.text = "\(year) © LEOIO Inc."
        
        
        if  (Auth.auth().currentUser == nil || (UserDefaults.standard.string(forKey: "loggedIn") == nil)) {
       
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.navigateToLoginScreen()
            }
       
            
        } else {
            
            // This will first check if user info is required, and if not, proceed to check authentication and load partner data

            viewModel.$userInfoRequired
                .combineLatest(viewModel.$isLoading)
                .filter { !$1 } // Only proceed when not loading
                .flatMap { [weak self] (userInfoRequired, _) -> AnyPublisher<Bool, Never> in
                    guard let strongSelf = self else { return Just(false).eraseToAnyPublisher() }

                    if strongSelf.hasNavigated {
                        return Just(false).eraseToAnyPublisher() // Prevent further navigation after the first
                    }

                    if userInfoRequired {
                        strongSelf.showRegistrationScreen()
                        strongSelf.hasNavigated = true // Set flag after successfully navigating
                        return Just(false).eraseToAnyPublisher()
                    } else {
                        return Just(true).eraseToAnyPublisher()
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] shouldNavigate in
                    guard let strongSelf = self, shouldNavigate, !strongSelf.hasNavigated else { return }
                    strongSelf.checkAuthenticationAndLoadPartnerData()
                    // Don't set hasNavigated here yet because it will be handled in checkAuthenticationAndLoadPartnerData
                }
                .store(in: &cancellables)

            viewModel.loadMyDataAndThenPartnerData()


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
       func checkAuthentication() {
           if let user = Auth.auth().currentUser {
               print("User is already signed in: \(user.uid)")
               navigateToMainScreen()
           } else {
               print("No user is signed in.")
               navigateToLoginScreen()
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
        tabBarVC.viewModel = self.viewModel
        updateRootViewController(to: tabBarVC)
    }

      // Navigate to the login screen
      func navigateToLoginScreen() {
          let loginVC = CoupleLoginViewController()
          updateRootViewController(to: loginVC)
      }
}




