//
//  CDTabbarController.swift
//  CoupDate
//
//  Created by mo on 2024-09-12.
//

import Foundation
import UIKit

class CDTabbarController: CardTabBarController {

    
    //public var viewModel : PartnerViewModel!
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
//        partnerVC.viewModel = self.viewModel

        
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
        
        guard let streakVC = storyboard.instantiateViewController(withIdentifier: "StreakViewController") as? StreakViewController else {
            print("Could not find StreakViewController with identifier 'MainTabbar'")
            return
        }
        
        if let dailyRecords = CDDataProvider.shared.dailyRecords {
            
            let chartVC = CDCareViewController()
//            chartVC.moodCounts = self.collectMoodDataForPieChart()
            let chartVCItem = UITabBarItem(title: "Insight", image: UIImage(named: "self_care"), selectedImage: nil)
            chartVC.tabBarItem = chartVCItem
            
            let nav = UINavigationController(rootViewController: chartVC)
            viewControllers = [partnerVC, streakVC,nav,dataEntryVC]

        } else {
            viewControllers = [partnerVC, streakVC,dataEntryVC]

        }
        
    }
    
    func collectMoodDataForPieChart() -> [String: Int] {
        // Assume `dailyRecords` contains the moods of the user
        var moodCounts: [String: Int] = [:]
        
        for (_, moods) in CDDataProvider.shared.dailyRecords! {
            for mood in moods.userMoods { // Assuming dailyRecords is of the form [Date: (userMoods: [String], partnerMoods: [String])]
                moodCounts[mood, default: 0] += 1
            }
            // Uncomment the following lines if you want to include partner moods as well
            /*
            for mood in moods.partnerMoods {
                moodCounts[mood, default: 0] += 1
            }
            */
        }
        
        return moodCounts
    }
}

