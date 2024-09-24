//
//  CDNotificationManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-10.
//

import Foundation
import UserNotifications


class CDNotificationManager {

    static let shared = CDNotificationManager()

    private init() {}

    // Request notification authorization
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification access granted.")
            } else if let error = error {
                print("Error requesting notification access: \(error.localizedDescription)")
            }
        }
    }

    // Cancel all daily notifications with a specific prefix
    func cancelPreviousDailyNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("daily9AMNotification") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // Cancel all previous mood-based notifications
    func cancelPreviousMoodNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("moodNotification") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // Schedule a daily notification at 9 AM with different motivational texts
    func scheduleDailyNotification(userName: String?) {
        cancelPreviousDailyNotifications()

        let content = UNMutableNotificationContent()
        let name = userName ?? "there"

        let motivationalTexts = [
            "A fresh day ahead, \(name)! Time to shine 🌟",
            "Good Morning, \(name)! Let’s make today awesome!",
            "New day, new opportunities, \(name)! What’s on your mind?",
            "Rise and shine, \(name)! What are you looking forward to?",
            "\(name), it’s a brand new day! How are you feeling?"
        ]

        content.title = motivationalTexts.randomElement()!
        content.body = "Check-in and let your partner know how you're feeling today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily9AMNotification-\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            }
        }
    }

    // Schedule mood-based notification
    func scheduleMoodNotification(mood: String, userName: String?) {
        cancelPreviousMoodNotifications()

        let content = UNMutableNotificationContent()
        let name = userName ?? "there"

        switch mood {
        case "Happy":
            content.title = ["Keep Smiling!", "Happiness is Contagious!", "Share your Joy!"].randomElement()!
            content.body = ["You were feeling happy earlier, keep the good vibes going!", "\(name), spread your happiness and brighten someone's day!", "Let your partner know what's making you happy today!"].randomElement()!
        case "Excited":
            content.title = ["Keep the Energy Flowing!", "Excitement Feels Good!", "You're Energized!"].randomElement()!
            content.body = ["Let that excitement fuel your day!", "What’s getting you pumped today, \(name)?", "\(name), use that excitement to motivate yourself!"].randomElement()!
        case "Loved":
            content.title = ["Love is Powerful!", "Feeling Loved?", "Spread the Love"].randomElement()!
            content.body = ["Feeling loved is a blessing. Show appreciation today.", "\(name), send some love back to your partner.", "Let your partner know how much they mean to you!"].randomElement()!
        case "Calm":
            content.title = ["Feeling at Peace?", "Embrace the Calm", "Stay Zen"].randomElement()!
            content.body = ["Keep your calm energy flowing, \(name).", "Take a moment to breathe and stay balanced.", "\(name), continue enjoying your peaceful day!"].randomElement()!
        case "Stressed":
            content.title = ["Feeling Overwhelmed?", "Take it Easy", "Stressful Times?"].randomElement()!
            content.body = ["Remember to take breaks, \(name).", "You got this! Take it one step at a time.", "Feeling stressed? Make time for yourself, \(name)."].randomElement()!
        case "Anxious":
            content.title = ["Everything Will Be Okay", "Feeling Nervous?", "Anxiety’s Just a Phase"].randomElement()!
            content.body = ["It’s okay to feel anxious, take it slow.", "Breathe deeply, you’ll get through this.", "Focus on what’s in your control, \(name)."].randomElement()!
        case "Sick":
            content.title = ["Rest Up!", "Take Care", "Feeling Under the Weather?"].randomElement()!
            content.body = ["Take it easy today, \(name). You need to recover.", "Don’t forget to hydrate and get plenty of rest.", "Let your partner know if you need any help!"].randomElement()!
        case "Period":
            content.title = ["Take it Easy", "Self-Care is Key", "Period Pains?"].randomElement()!
            content.body = ["Remember to rest and prioritize self-care.", "\(name), take some time for yourself today.", "It’s okay to relax and take a break during tough days!"].randomElement()!
        case "Lazy":
            content.title = ["Feeling Lazy?", "Taking it Slow?", "Chill Mode On"].randomElement()!
            content.body = ["It’s okay to relax, \(name). Recharge yourself.", "\(name), sometimes being lazy is self-care.", "Take it easy, your energy will return!"].randomElement()!
        case "Meh":
            content.title = ["Feeling 'Meh'?", "A Little Off Today?", "Not Feeling it?"].randomElement()!
            content.body = ["It’s okay to have 'meh' days, \(name). Tomorrow is another chance!", "A bit low on energy? Take a breather, \(name).", "\(name), sometimes 'meh' leads to something better. Keep going!"].randomElement()!
        case "Vulnerable":
            content.title = ["Feeling Vulnerable?", "It’s Okay to Be Open", "Stay Strong"].randomElement()!
            content.body = ["It’s okay to feel vulnerable, \(name). Lean on those around you.", "Open up to someone close and share your feelings.", "Vulnerability is strength, \(name). Don't shy away from it."].randomElement()!
        case "Balanced":
            content.title = ["In Balance", "Feeling Centered?", "Stay Grounded"].randomElement()!
            content.body = ["You’re in a great place, \(name). Keep that balance flowing.", "Being balanced is key, keep nurturing that.", "\(name), stay grounded and enjoy the equilibrium."].randomElement()!
        default:
            content.title = "How Are You?"
            content.body = "Let us know how you're feeling and check in."
        }

        content.sound = .default

        // Unique identifier for mood notification
        let notificationIdentifier = "moodNotification-\(mood)-\(UUID().uuidString)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false) // 15 minutes later
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling mood notification: \(error.localizedDescription)")
            }
        }
    }

    // Schedule mood notifications based on an array of moods
    func scheduleMoodBasedNotifications(moods: [String], userName: String?) {
        let prioritizedMood = prioritizeMood(moods: moods)
        scheduleMoodNotification(mood: prioritizedMood, userName: userName)
    }

    // Method to prioritize moods based on need (adjust priority as needed)
    private func prioritizeMood(moods: [String]) -> String {
        let moodPriority = ["Sick", "Period", "Stressed", "Anxious", "Vulnerable", "Calm", "Excited", "Loved", "Happy", "Lazy", "Meh"]

        // Return the highest-priority mood from the user's selections
        for mood in moodPriority {
            if moods.contains(mood) {
                return mood
            }
        }

        // Default to the first mood if none match
        return moods.first ?? "Calm"
    }

    // Method to schedule both daily and mood-based notifications
    func scheduleNotifications(userName: String?, moods: [String]) {
        scheduleDailyNotification(userName: userName)
        scheduleMoodBasedNotifications(moods: moods, userName: userName)
    }
}
