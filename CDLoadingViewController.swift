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


class CDLoadingViewController : UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var copyrightLabel: UILabel!
    private var viewModel = PartnerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        animationView!.animationSpeed = 1.0
        
        // 6. Play animation
        
        animationView!.play()
        
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    let partnerActivityVC = PartnerActivityViewController()
                    partnerActivityVC.poopData = poopData
                    partnerActivityVC.sleepData = sleepData
                    
                    // Navigate to PartnerActivityViewController
                    UIApplication.shared.keyWindow?.rootViewController = partnerActivityVC
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadPartnerData()
    }
    
    
}




