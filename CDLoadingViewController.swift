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
    // Array of messages
    let messages = [
        "Take a deep breath and connect with your partner today.",
        "Small moments of care can make a big difference.",
        "Your well-being journey starts with understanding and support."
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        animationView!.animationSpeed = 1.0
        
        // 6. Play animation
        
        animationView!.play()
        
        showMessagesWithAnimation()
        
        let year = Calendar.current.component(.year, from: Date())
        self.copyrightLabel.text = "\(year) © LEOIO Inc."
        
        
        
        // Bind to the ViewModel's isLoading and errorMessage
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    // Show loading indicator
                } else {
                    // Hide loading indicator
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    // Show error message
                    print(errorMessage)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$poopData
            .combineLatest(viewModel.$sleepData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] poopData, sleepData in
                guard let self = self else { return }
                
                // Add a delay of 3 seconds before transitioning to PartnerActivityViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {

                    if let user = Auth.auth().currentUser, let _ = UserDefaults.standard.string(forKey: "loggedIn") {
                        print("User is already signed in: \(user.uid)")
                        self.navigateToMainScreen()
                        
                    } else {
                        print("No user is signed in.")
                        self.navigateToLoginScreen()
                    }

                }
            }
            .store(in: &cancellables)
        
        viewModel.loadPartnerData()
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
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? UITabBarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }
        
        // Find the PartnerActivityViewController in the tab bar's view controllers
        if let partnerActivityVC = tabBarVC.viewControllers?.first(where: { $0 is PartnerActivityViewController }) as? PartnerActivityViewController {
            // Assign the data to PartnerActivityViewController
            partnerActivityVC.poopData = viewModel.poopData
            partnerActivityVC.sleepData = viewModel.sleepData
        }
        
        // Set the UITabBarController as the root view controller
        updateRootViewController(to: tabBarVC)
    }

      // Navigate to the login screen
      func navigateToLoginScreen() {
          let loginVC = CoupleLoginViewController()
          updateRootViewController(to: loginVC)
      }
    
    
    func updateRootViewController(to viewController: UIViewController) {
        // Ensure we are running on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateRootViewController(to: viewController)
            }
            return
        }

        if let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let window = windowScene.windows.first {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        } else {
            print("No active window scene found.")
        }
    }
    
    
}




