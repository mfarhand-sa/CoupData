import Foundation
import Lottie
import HorizonCalendar
import FittedSheets

class StreakViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var streakCalendarView: UIView!
    private var  calendarView :CalendarView!
    var heartAnimationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.0
        animationView!.play()
        self.label.font = UIFont(name: "Poppins-Regular", size: 20)
        if CDDataProvider.shared.partnerID == nil {
            self.label.text = "You'll be able to track your streak with your partner once they join you."
            
            let smallAnimationView = LottieAnimationView(name: "LoginAnimtation")
            self.streakCalendarView.addSubview(smallAnimationView)
            
            smallAnimationView.contentMode = .scaleAspectFit
            smallAnimationView.loopMode = .loop
            smallAnimationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                smallAnimationView.leadingAnchor.constraint(equalTo: self.streakCalendarView.leadingAnchor),
                smallAnimationView.trailingAnchor.constraint(equalTo: self.streakCalendarView.trailingAnchor),
                smallAnimationView.topAnchor.constraint(equalTo: self.streakCalendarView.topAnchor),
                smallAnimationView.bottomAnchor.constraint(equalTo: self.streakCalendarView.bottomAnchor)
            ])
            smallAnimationView.play()
            return

        }
        
        
        animationView.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        
        animationView.addGestureRecognizer(longPressGesture)


    }
    
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("Long press began")
            
            Haptic.vibrating() // Trigger haptic feedback

            // Create the heart reaction animation
            if heartAnimationView == nil { // Only create if it's not already created
                heartAnimationView = LottieAnimationView(name: "reaction1")
                heartAnimationView?.contentMode = .scaleAspectFit
                heartAnimationView?.loopMode = .loop
                heartAnimationView?.translatesAutoresizingMaskIntoConstraints = false

                // Add the heart animation as a subview on top of the main animation view
                if let heartAnimationView = heartAnimationView {
                    self.animationView.addSubview(heartAnimationView)
                    
                    // Position the heart animation over the center of the existing animation view
                    NSLayoutConstraint.activate([
                        heartAnimationView.centerXAnchor.constraint(equalTo: self.animationView.centerXAnchor),
                        heartAnimationView.centerYAnchor.constraint(equalTo: self.animationView.centerYAnchor),
                        heartAnimationView.widthAnchor.constraint(equalTo: self.animationView.widthAnchor),
                        heartAnimationView.heightAnchor.constraint(equalTo: self.animationView.heightAnchor),
                        // Same width as animationView                        heartAnimationView.heightAnchor.constraint(equalToConstant: 200)
                    ])

                    heartAnimationView.isUserInteractionEnabled = false
                    heartAnimationView.play()
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                           // self.showCategorySelectionAlert()
                        self.showMSGOptions()
                            // Cancel the gesture by setting its state to .ended
                            gesture.isEnabled = false
                            gesture.isEnabled = true
                    }
                    
                    
                }
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Stop the animation and remove it when the user lifts their finger
            if let heartAnimationView = heartAnimationView {
                print("Long press ended, animation stopped")
                heartAnimationView.stop() // Stop the animation
                heartAnimationView.removeFromSuperview() // Remove from the view hierarchy
                self.heartAnimationView = nil // Clear the reference
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    
//                }
            }
        } else {
            Haptic.intenesVibrating() // Trigger haptic feedback

        }
    }
    
    
    func displayRandomMessage(from category: CDMessageHelper.CDMessageCategory) {
           // Get a random message from the selected category
           if let randomMessage = CDMessageHelper.getRandomMessage(from: category) {
               print(randomMessage) // For now, we're just printing the message
               
               FirebaseManager.shared.sendMessageToPartner(partnerUid: UserManager.shared.partnerUserID!, message:randomMessage , messageType: "normal")
               
               CustomAlerts.displayNotification(title: "Sent 🚀", message:randomMessage, view: self.view,fromBottom: true)

               
           } else {
               print("No messages available for this category.")
           }
       }

    
    func showCategorySelectionAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Ready for a surprise?", message: "We'll send a mystery message to your partner based on your choice!", preferredStyle: .alert)
        
        // Create actions for each category
        let loveAction = UIAlertAction(title: "Love 💌", style: .default) { _ in
            self.displayRandomMessage(from: .love)
        }
        
        let supportiveAction = UIAlertAction(title: "Supportive 💪", style: .default) { _ in
            self.displayRandomMessage(from: .supportive)
        }
        
        let intimacyAction = UIAlertAction(title: "Intimacy ❤️‍🔥", style: .default) { _ in
            self.displayRandomMessage(from: .intimacy)
        }
        
        let dirtyAction = UIAlertAction(title: "Dirty 🔥", style: .default) { _ in
            self.displayRandomMessage(from: .dirty)
        }
        
        // Add the actions to the alert controller
        alertController.addAction(dirtyAction)
        alertController.addAction(loveAction)
        alertController.addAction(supportiveAction)
        alertController.addAction(intimacyAction)
        
        // Optionally, add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel the surprise!🥴", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        guard CDDataProvider.shared.partnerID != nil else { return }
        

        loadUserAndPartnerData(userID: UserManager.shared.currentUserID!, partnerID: UserManager.shared.partnerUserID!) { streakCount, startDate, endDate, error in
            
            if let streakCount = streakCount, let startDate = startDate, let endDate = endDate {
                print("The current streak is: \(streakCount) days")
                
                let fullText = "\(streakCount) days and counting—your bond with your partner keeps growing!"
                let attributedString = NSMutableAttributedString(string: fullText)
                let boldRange = (fullText as NSString).range(of: "\(streakCount) days")
                
                attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 24)!, range: boldRange)
                self.label.attributedText = attributedString
                
                // Check if `calendarView` already exists, update its content
                if self.calendarView != nil {
                    // Update the content of the existing calendar view
                    self.calendarView.setContent(self.makeContent(startDate: startDate, endDate: endDate))
                } else {
                    // Initialize and add the calendar view if it doesn't exist yet
                    self.calendarView = CalendarView(initialContent: self.makeContent(startDate: startDate, endDate: endDate))
                    
                    self.streakCalendarView.addSubview(self.calendarView)
                    self.calendarView.translatesAutoresizingMaskIntoConstraints = false

                    NSLayoutConstraint.activate([
                        self.calendarView.leadingAnchor.constraint(equalTo: self.streakCalendarView.leadingAnchor, constant: 10),
                        self.calendarView.trailingAnchor.constraint(equalTo: self.streakCalendarView.trailingAnchor, constant: -10),
                        self.calendarView.topAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.topAnchor),
                        self.calendarView.bottomAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.bottomAnchor),
                    ])
                }
                
                // Scroll to the specific month
                self.calendarView.scroll(
                    toMonthContaining: endDate,
                    scrollPosition: .centered,
                    animated: false // Set to true if you want animation
                )
            } else if let error = error {
                print("Error: \(error)")
            }
        }
        
        
        
        
        
        
    }
    
    private func makeContent(startDate: Date, endDate:Date) -> CalendarViewContent {
        let calendar = Calendar.current
        let highlightStartDate = startDate
        let highlightEndDate = endDate
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        //        let startDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: components.day))!
        let startDate = calendar.date(from: DateComponents(year: 2024, month: 01, day: 01))!
        
        let endDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
        
        
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
        .interMonthSpacing(24)
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .dayItemProvider { day in
            let dayDate = calendar.date(from: day.components)!
            let isInHighlightedRange = (highlightStartDate...highlightEndDate).contains(dayDate)
            
            if isInHighlightedRange == true {
                print("YESS")
            }
            return CalendarItemModel<CustomDayView>(
                invariantViewProperties: CustomDayView.InvariantViewProperties(isHighlighted: isInHighlightedRange),
                viewModel: CustomDayView.ViewModel(dayText: "\(day.day)")
            )
        }
    }
    
    
    
    // Method to load user and partner streaks
    func loadUserAndPartnerData(userID: String, partnerID: String, daysToCheck: Int = 30, completion: @escaping (Int?, Date?, Date?, Error?) -> Void) {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -daysToCheck, to: endDate)!
        
        FirebaseManager.shared.streakRecords(for: userID, from: startDate, to: endDate) { userResult in
            switch userResult {
            case .success(let userRecords):
                FirebaseManager.shared.streakRecords(for: partnerID, from: startDate, to: endDate) { partnerResult in
                    switch partnerResult {
                    case .success(let partnerRecords):
                        let streakCount = self.calculateStreak(userRecords: userRecords, partnerRecords: partnerRecords)
                        let actualStartDate = self.getActualStartDate(from: userRecords, partnerRecords: partnerRecords)
                        let actualEndDate = self.getActualEndDate(from: userRecords, partnerRecords: partnerRecords)
                        completion(streakCount, actualStartDate, actualEndDate, nil)
                    case .failure(let partnerError):
                        completion(nil, nil, nil, partnerError)
                    }
                }
            case .failure(let userError):
                completion(nil, nil, nil, userError)
            }
        }
    }
    
    func getActualStartDate(from userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Date? {
        let validDates = userRecords.keys.filter { userRecords[$0] == true && partnerRecords[$0] == true }
        return validDates.min() // The earliest date in the streak
    }
    
    func getActualEndDate(from userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Date? {
        let validDates = userRecords.keys.filter { userRecords[$0] == true && partnerRecords[$0] == true }
        return validDates.max() // The latest date in the streak
    }
    
    
    
    func calculateStreak(userRecords: [Date: Bool], partnerRecords: [Date: Bool]) -> Int {
        // Sort the records by date in descending order (most recent first)
        let sortedUserRecords = userRecords.keys.sorted(by: >)
        let sortedPartnerRecords = partnerRecords.keys.sorted(by: >)
        
        var streakCount = 0
        var lastValidDate: Date?
        
        // Get today's date
        let today = Calendar.current.startOfDay(for: Date())
        
        // Flag to track if we skip today's check
        var skipToday = true
        
        for date in sortedUserRecords {
            // Skip today if not both users have checked in today
            if Calendar.current.isDate(date, inSameDayAs: today) {
                if userRecords[date] != true || partnerRecords[date] != true {
                    continue
                }
            }
            
            // Check if both users have records for this date
            if let userRecordExists = userRecords[date], let partnerRecordExists = partnerRecords[date], userRecordExists && partnerRecordExists {
                if let lastDate = lastValidDate {
                    // Check if this record is exactly one day after the last valid record
                    if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: lastDate)!) {
                        streakCount += 1
                        lastValidDate = date // Continue the streak
                    } else {
                        // Streak is broken, stop here
                        break
                    }
                } else {
                    // First valid record, start the streak
                    streakCount += 1
                    lastValidDate = date
                }
            } else {
                // Break the loop if we don't have a match for both users' records (but ignore today)
                if !Calendar.current.isDate(date, inSameDayAs: today) {
                    break
                }
            }
        }
        
        return streakCount
    }
    
    
    
    func showMSGOptions() {
        
        
        let options = SheetOptions(
            // The full height of the pull bar. The presented view controller will treat this area as a safearea inset on the top
            pullBarHeight: 24,
            
            // The corner radius of the shrunken presenting view controller
            //            presentingViewCornerRadius: 20,
            
            // Extends the background behind the pull bar or not
            shouldExtendBackground: true,
            
            // Attempts to use intrinsic heights on navigation controllers. This does not work well in combination with keyboards without your code handling it.
            setIntrinsicHeightOnNavigationControllers: true,
            
            // Pulls the view controller behind the safe area top, especially useful when embedding navigation controllers
            useFullScreenMode: true,
            
            // Shrinks the presenting view controller, similar to the native modal
            shrinkPresentingViewController: true,
            
            // Determines if using inline mode or not
            useInlineMode: false,
            
            // Adds a padding on the left and right of the sheet with this amount. Defaults to zero (no padding)
            horizontalPadding: 0,
            
            // Sets the maximum width allowed for the sheet. This defaults to nil and doesn't limit the width.
            maxWidth: nil
        )
        
        let listVC = ListViewController()
        listVC.listTitle = "Ready for a surprise?" // Set the title
        listVC.setItems(["Dirty 🔥","Love 💌","Supportive 💪", "Intimacy ❤️‍🔥"]) // Set the items array
        listVC.delegate = self
        
        let sheetController = SheetViewController(controller: listVC    , sizes: [.marginFromTop(400)], options: options)
        self.present(sheetController, animated: true)
        
    }
}

extension StreakViewController: ListViewControllerDelegate {
    func listViewController(_ controller: ListViewController, didSelectItem item: String) {
        // Handle the selected item here
        print("Selected item: \(item)")
        
        if let category = CDMessageHelper.category(for: item) {
                    // Call your method to display the random message
                    self.displayRandomMessage(from: category)
                } else {
                    print("Category not found for item: \(item)")
                }
        
    }
}


struct CustomDayView: CalendarItemViewRepresentable {
    
    typealias ViewType = HighlightableDayView
    
    struct InvariantViewProperties: Hashable {
        let isHighlighted: Bool
        
        public init(isHighlighted: Bool) {
            self.isHighlighted = isHighlighted
        }
    }
    
    struct ViewModel: Equatable {
        let dayText: String
        
        public init(dayText: String) {
            self.dayText = dayText
        }
        
        public static func ==(lhs: ViewModel, rhs: ViewModel) -> Bool {
            return lhs.dayText == rhs.dayText
        }
    }
    
    // This method creates the view for each calendar day
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> HighlightableDayView {
        let view = HighlightableDayView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        // Set the highlight property based on the invariant properties
        view.isHighlighted = invariantViewProperties.isHighlighted
        
        return view
    }
    
    // This method updates the view with the provided ViewModel
    static func setViewModel(_ viewModel: ViewModel, on view: HighlightableDayView) {
        let label = view.subviews.compactMap { $0 as? UILabel }.first
        label?.text = viewModel.dayText
        label?.font = UIFont(name: "Poppins-Regular", size: 16)
        
        
        // Set the background color based on the custom isHighlighted property
        view.backgroundColor = view.isHighlighted ? .accent : UIColor.clear
    }
}

// Custom UIView that includes a highlight property
class HighlightableDayView: UIView {
    var isHighlighted: Bool = false
}
