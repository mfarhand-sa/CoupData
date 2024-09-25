import WatchConnectivity
import WatchKit

class StreakInterfaceController: WKInterfaceController, WCSessionDelegate {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context) // Correctly overriding the superclass method

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate() // Correctly activating the session
        }
    }

    @IBAction func sendMessageToPartner() {
        if WCSession.default.isReachable {
            let messageData: [String: Any] = [
                "message": "Hey, I’m sending this from the watch!",
                "category": "supportive" // or "love", "intimacy", etc.
            ]
            WCSession.default.sendMessage(messageData, replyHandler: nil) { error in
                print("Error sending message to iPhone: \(error.localizedDescription)")
            }
        } else {
            print("iPhone is not reachable")
        }
    }

    // WCSessionDelegate stubs
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    // This is needed if you want to handle incoming messages from the iPhone to the watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from iPhone: \(message)")
        // Handle message data here
    }
}
