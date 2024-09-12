//
//  CDTabbarController.swift
//  CoupDate
//
//  Created by mo on 2024-09-12.
//

import Foundation
import CardTabBar

class CDTabbarController: CardTabBarController {

    
    public var viewModel : PartnerViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupUI()
    }

    func setupUI() {
        tabBar.tintColor = .white
        tabBar.backgroundColor = .CDBackground
        tabBar.indicatorColor = .accent
    }
    
    public func setupViewController() {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let partnerVC = storyboard.instantiateViewController(withIdentifier: "PartnerActivityViewController") as? PartnerActivityViewController else {
            print("Could not find PartnerActivityViewController with identifier 'MainTabbar'")
            return
        }
        partnerVC.viewModel = self.viewModel

        
        guard let dataEntryVC = storyboard.instantiateViewController(withIdentifier: "DataEntryViewController") as? DataEntryViewController else {
            print("Could not find DataEntryViewController with identifier 'MainTabbar'")
            return
        }
        
        var imageName = "myself-male"
        if CDDataProvider.shared.gender == "Female" {
            imageName = "myself-female"
        }
        
        let dataEntryVCTabItem = UITabBarItem(title: "Me", image: UIImage(named: imageName), selectedImage: nil)
        dataEntryVC.tabBarItem = dataEntryVCTabItem

        
        guard let streakVC = storyboard.instantiateViewController(withIdentifier: "StreakViewController") as? StreakViewController else {
            print("Could not find StreakViewController with identifier 'MainTabbar'")
            return
        }        
        streakVC.viewModel = self.viewModel
        viewControllers = [partnerVC, streakVC,dataEntryVC]
    }
}

