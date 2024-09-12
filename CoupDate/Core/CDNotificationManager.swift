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

    // Cancel all daily notifications to avoid duplicates
    func cancelPreviousDailyNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily9AMNotification"])
    }

    // Cancel all previous mood-based notifications
    func cancelPreviousMoodNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Schedule a daily notification at 9AM
    func scheduleDailyNotification(userName: String?) {
        cancelPreviousDailyNotifications()

        let content = UNMutableNotificationContent()
        let name = userName ?? "there"
        content.title = "Good Morning, \(name)!"
        content.body = "Start your day off right! How are you feeling today? Check-in and let your partner know."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily9AMNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            }
        }
    }

    // Schedule mood-based notification 2 hours later
    func scheduleMoodNotification(mood: String, userName: String?) {
        // Cancel any previous mood notifications before scheduling a new one
        cancelPreviousMoodNotifications()

        let content = UNMutableNotificationContent()
        let name = userName ?? "there"

        switch mood {
        case "Happy":
            content.title = "Keep the Good Vibes Going!"
            content.body = "You were feeling happy earlier! Keep it up, \(name). Spread your joy today!"
        case "Excited":
            content.title = "Fuel that Excitement!"
            content.body = "\(name), let that excitement continue! What's keeping you motivated today?"
        case "Loved":
            content.title = "Share the Love!"
            content.body = "\(name), feel the love and let your partner know how much they mean to you."
        case "Calm":
            content.title = "Stay in the Moment"
            content.body = "You've been calm today. Take a deep breath and stay balanced."
        case "Stressed":
            content.title = "Take a Break!"
            content.body = "\(name), feeling stressed? Take 5 minutes to relax and breathe."
        case "Anxious":
            content.title = "You Got This!"
            content.body = "It's okay to feel anxious, \(name). You've got everything under control."
        default:
            content.title = "How Are You?"
            content.body = "Let us know how you're feeling and check in."
        }

        content.sound = .default

        // Create a unique identifier for the mood notification to easily cancel it
        let notificationIdentifier = "moodNotification-\(mood)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false) // 2 hours later
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
        let moodPriority = ["Stressed", "Anxious", "Calm", "Excited", "Loved", "Happy"]

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

