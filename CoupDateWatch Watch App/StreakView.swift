//
//  StreakView.swift
//  CoupDateWatch Watch App
//
//  Created by mo on 2024-09-24.
//

import Foundation
import SwiftUI
import WatchKit
import WatchConnectivity

struct StreakView: View {
    @State private var showCategoryPicker = false
    @State private var selectedCategory: String? = nil
    @State private var replyMessage: String? = nil
    private let categoryOptions = ["Love 💌", "Supportive 💪", "Intimacy ❤️‍🔥", "Dirty 🔥"]
    
    @State var lottieFile: String = "Streak"
    @ObservedObject var viewModel: LottieViewModel = .init()
    
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .onAppear {
                    self.viewModel.loadAnimationFromFile(filename: lottieFile)
                    activateSession() // Activate WCSession
                }
                .onLongPressGesture {
                    self.replyMessage = nil
                    self.showCategoryPicker.toggle()
                }
            
            if let selectedCategory = selectedCategory, replyMessage == nil {
                Text("Sending a mystery message \(selectedCategory)")
                    .font(.footnote)
                    .foregroundColor(.accent)
                    .padding()
            }
            if let replyMessage = replyMessage {
                Text(replyMessage)
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .sheet(isPresented: $showCategoryPicker, onDismiss: {
            if let selectedCategory = selectedCategory {
                sendCategoryToiPhone(selectedCategory)
            }
        }) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
    }
    
    // Activate the WCSession for watchOS
    func activateSession() {
        WatchSessionManager.shared.startSession()
    }
    
    // Send category message to iPhone
    func sendCategoryToiPhone(_ category: String) {
        if WCSession.default.isReachable {
            let message = ["message": category]
            WCSession.default.sendMessage(message, replyHandler: { reply in
                print("Received reply: \(reply)")
                if let replyString = reply["Status"] as? String {
                    self.replyMessage = replyString
                }
                
            }, errorHandler: { error in
                print("Error sending message: \(error)")
            })
        } else {
            print("iPhone is not reachable")
        }
    }
    
    
    
    func sendMessageToPhone() {
        if WCSession.default.isReachable {
            let message = ["message": "Hello from the watch!"]
            WCSession.default.sendMessage(message, replyHandler: { reply in
                print("Received reply: \(reply)")
            }, errorHandler: { error in
                print("Error sending message: \(error)")
            })
        } else {
            print("iPhone is not reachable")
        }
    }
    
    
    
    // Function to get the message for each category
    func getMessageForCategory(_ category: String) -> String {
        switch category {
        case "Love 💌":
            return "Sending you all my love 💕"
        case "Supportive 💪":
            return "You got this! 💪"
        case "Intimacy ❤️‍🔥":
            return "Can't wait to see you tonight ❤️‍🔥"
        case "Dirty 🔥":
            return "Let's turn up the heat 🔥"
        default:
            return "Mystery Message"
        }
    }
}

struct CategoryPickerView: View {
    @Binding var selectedCategory: String?
    let categoryOptions = ["Love 💌", "Supportive 💪", "Intimacy ❤️‍🔥", "Dirty 🔥"]
    
    var body: some View {
        VStack {
            Text("Select a Category").font(.headline)
            
            List(categoryOptions, id: \.self) { category in
                Button(action: {
                    self.selectedCategory = category
                }) {
                    Text(category)
                }
            }
        }
    }
}
