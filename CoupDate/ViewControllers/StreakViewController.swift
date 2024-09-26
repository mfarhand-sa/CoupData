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
    private var dailyRecords: [Date: (userMoods: [String], partnerMoods: [String])] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.0
        animationView!.play()
        self.label.font = UIFont(name: "Poppins-Regular", size: 18)
        
        if CDDataProvider.shared.partnerID != nil {
            animationView.isUserInteractionEnabled = true
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.3
            
            animationView.addGestureRecognizer(longPressGesture)
        }
        
        if CDDataProvider.shared.partnerID == nil || CDDataProvider.shared.streak == nil {
            self.label.text = "Your streak data will appear once both you and your partner start checking in."
            
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
        
        
        
        
        // Check if cached data exists
         if let cachedStreak = CDDataProvider.shared.streak,
            let cachedStartDate = CDDataProvider.shared.startDate,
            let cachedEndDate = CDDataProvider.shared.endDate,
            let cachedDailyRecords = CDDataProvider.shared.dailyRecords {
             
             // Use cached data to set up the calendar and label
             self.setupCalendarAndLabel(streakCount: cachedStreak, startDate: cachedStartDate, endDate: cachedEndDate, dailyRecords: cachedDailyRecords)
             
             

             




         }

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
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
        if let randomMessage = CDMessageHelper.sendRandomMessageBasedOnGender(category: category, userGender: CDDataProvider.shared.gender ?? "") {
               print(randomMessage) // For now, we're just printing the message
               
               FirebaseManager.shared.sendMessageToPartner(partnerUid: UserManager.shared.partnerUserID!, message:randomMessage , messageType: category.rawValue)
               
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
        
        
        streakCalendarView.backgroundColor = .white
        
        // Fetch the latest data and update the calendar
        loadUserAndPartnerData(userID: UserManager.shared.currentUserID!, partnerID: UserManager.shared.partnerUserID!) { streakCount, startDate, endDate, dailyRecords, error in
            if let streakCount = streakCount, let startDate = startDate, let endDate = endDate {
                // Cache the data
                CDDataProvider.shared.dailyRecords = dailyRecords
                CDDataProvider.shared.streak = streakCount
                CDDataProvider.shared.startDate = startDate
                CDDataProvider.shared.endDate = endDate
                
                // Update the calendar and label
                self.setupCalendarAndLabel(streakCount: streakCount, startDate: startDate, endDate: endDate, dailyRecords: dailyRecords)
            } else if let error = error {
                print("Error: \(error)")
            }
        }

    }
    
    
    private func setupCalendarAndLabel(streakCount: Int, startDate: Date, endDate: Date, dailyRecords: [Date: (userMoods: [String], partnerMoods: [String])]) {
        // Update the label with the streak count
        self.dailyRecords = dailyRecords
        let fullText = "\(streakCount) days and counting—your bond with your partner keeps growing!"
        let attributedString = NSMutableAttributedString(string: fullText)
        let boldRange = (fullText as NSString).range(of: "\(streakCount) days")
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 22)!, range: boldRange)
        self.label.attributedText = attributedString

        // Update or create the calendar view
        if self.calendarView != nil {
            // Update the content of the existing calendar view
            self.calendarView.setContent(self.makeContent(startDate: startDate, endDate: endDate, dailyRecords: dailyRecords))
        } else {
            // Initialize and add the calendar view if it doesn't exist yet
            self.calendarView = CalendarView(initialContent: self.makeContent(startDate: startDate, endDate: endDate, dailyRecords: dailyRecords))
            self.streakCalendarView.addSubview(self.calendarView)
            self.calendarView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                self.calendarView.leadingAnchor.constraint(equalTo: self.streakCalendarView.leadingAnchor, constant: 10),
                self.calendarView.trailingAnchor.constraint(equalTo: self.streakCalendarView.trailingAnchor, constant: -10),
                self.calendarView.topAnchor.constraint(equalTo: self.streakCalendarView.safeAreaLayoutGuide.topAnchor),
                self.calendarView.bottomAnchor.constraint(equalTo: self.streakCalendarView.safeAreaLayoutGuide.bottomAnchor),
            ])
        }

        self.calendarView.daySelectionHandler = { [weak self] day in
            guard let self = self else { return }

            // Convert the selected day to a Date object
            let calendar = Calendar.current
            let selectedDate = calendar.date(from: day.components)!

            // Check if there are any records for the selected date
            if let moods = self.dailyRecords[selectedDate], (!moods.userMoods.isEmpty || !moods.partnerMoods.isEmpty) {
                // The selected date has mood data, show mood information
                self.showSelectedDateInfo(date: selectedDate, moods: moods)
            } else {
                // No records found for the selected date, ignore selection
                return
            }
        }

        // Scroll to the specific month
        self.calendarView.scroll(
            toMonthContaining: endDate,
            scrollPosition: .centered,
            animated: false // Set to true if you want animation
        )
    }

    
    
    // Update `showSelectedDateInfo` to properly display mood data
    func showSelectedDateInfo(date: Date, moods: (userMoods: [String], partnerMoods: [String])) {
        // Format the date as needed
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)

        // Prepare the mood data for display
        let userMoodsString = moods.userMoods.isEmpty ? "No mood data" : moods.userMoods.joined(separator: ", ")
        let partnerMoodsString = moods.partnerMoods.isEmpty ? "No mood data" : moods.partnerMoods.joined(separator: ", ")

        // Create the message to display
        let message = "Your Moods: \(userMoodsString)\nPartner's Moods: \(partnerMoodsString)"

        // Show an alert or any other UI to indicate the selected date
        let alertController = UIAlertController(
            title: "Date: \(dateString)",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true) {
        }
    }

    
    // In StreakViewController
    func collectMoodDataForPieChart() -> [String: Int] {
        // Assume `dailyRecords` contains the moods of the user
        var moodCounts: [String: Int] = [:]
        
        for (_, moods) in dailyRecords {
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

    func showPieChart() {
        let moodCounts = collectMoodDataForPieChart()
        
        // Initialize PieChartViewController
        let pieChartVC = PieChartViewController()
        
        // Pass moodCounts to PieChartViewController
        pieChartVC.moodCounts = moodCounts
        
        // Present or push the PieChartViewController
        self.present(pieChartVC, animated: true, completion: nil)
    }







    
//    private func makeContent(startDate: Date, endDate: Date, dailyRecords: [Date: (userMoods: [String], partnerMoods: [String])]) -> CalendarViewContent {
//        let calendar = Calendar.current
//        let highlightDates = dailyRecords.keys // Only these dates should be selectable and highlighted
//
//        let visibleStartDate = calendar.date(from: DateComponents(year: 2024, month: 01, day: 01))!
//        let visibleEndDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
//
//        return CalendarViewContent(
//            calendar: calendar,
//            visibleDateRange: visibleStartDate...visibleEndDate,
//            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
//        )
//        .interMonthSpacing(24)
//        .verticalDayMargin(8)
//        .horizontalDayMargin(8)
//        .dayItemProvider { day in
//            let dayDate = calendar.date(from: day.components)!
//            let isInHighlightedRange = highlightDates.contains(dayDate)
//
//            return CalendarItemModel<CustomDayView>(
//                invariantViewProperties: CustomDayView.InvariantViewProperties(isHighlighted: isInHighlightedRange),
//                viewModel: CustomDayView.ViewModel(dayText: "\(day.day)")
//            )
//        }
//    }
    
    
    private func makeContent(startDate: Date, endDate: Date, dailyRecords: [Date: (userMoods: [String], partnerMoods: [String])]) -> CalendarViewContent {
        let calendar = Calendar.current
        
        // Filter highlight dates to include only dates where both user and partner have records (ignoring whether they contain moods)
        let highlightDates = dailyRecords.keys.filter { date in
            if let records = dailyRecords[date] {
                return records.userMoods != nil && records.partnerMoods != nil
            }
            return false
        }

        let visibleStartDate = calendar.date(from: DateComponents(year: 2024, month: 01, day: 01))!
        let visibleEndDate = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!

        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: visibleStartDate...visibleEndDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
        .interMonthSpacing(24)
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .dayItemProvider { day in
            let dayDate = calendar.date(from: day.components)!
            let isInHighlightedRange = highlightDates.contains(dayDate)

            return CalendarItemModel<CustomDayView>(
                invariantViewProperties: CustomDayView.InvariantViewProperties(isHighlighted: isInHighlightedRange),
                viewModel: CustomDayView.ViewModel(dayText: "\(day.day)")
            )
        }
    }





    // Helper method to get all streak dates
    private func getStreakDates(startDate: Date, endDate: Date) -> Set<Date> {
        var streakDates: Set<Date> = []
        var currentDate = startDate

        while currentDate <= endDate {
            streakDates.insert(currentDate)
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }

        return streakDates
    }

    
    
    
    // Method to load user and partner streaks
    
    func loadUserAndPartnerData(userID: String, partnerID: String, daysToCheck: Int = 30, completion: @escaping (Int?, Date?, Date?, [Date: (userMoods: [String], partnerMoods: [String])], Error?) -> Void) {
        let endDate = Date() // Fixed typo
        let startDate = Calendar.current.date(byAdding: .day, value: -daysToCheck, to: endDate)!

        FirebaseManager.shared.streakRecords(for: userID, from: startDate, to: endDate) { userResult in
            switch userResult {
            case .success(let userRecords):
                FirebaseManager.shared.streakRecords(for: partnerID, from: startDate, to: endDate) { partnerResult in
                    switch partnerResult {
                    case .success(let partnerRecords):
                        var combinedRecords: [Date: (userMoods: [String], partnerMoods: [String])] = [:]

                        // Combine user and partner records into a single dictionary
                        let allDates = Array(Set(userRecords.keys).union(Set(partnerRecords.keys)))
                        for date in allDates {
                            let userMoods = userRecords[date] ?? []
                            let partnerMoods = partnerRecords[date] ?? []
                            combinedRecords[date] = (userMoods: userMoods, partnerMoods: partnerMoods)
                        }

                        // Calculate the streak count using the updated calculateStreak method
                        let streakCount = self.calculateStreak(userRecords: userRecords, partnerRecords: partnerRecords)
                        
                        // Find the actual start and end dates
                        let actualStartDate = self.getActualStartDate(from: userRecords, partnerRecords: partnerRecords)
                        let actualEndDate = self.getActualEndDate(from: userRecords, partnerRecords: partnerRecords)
                        
                        completion(streakCount, actualStartDate, actualEndDate, combinedRecords, nil)
                    case .failure(let partnerError):
                        completion(nil, nil, nil, [:], partnerError)
                    }
                }
            case .failure(let userError):
                completion(nil, nil, nil, [:], userError)
            }
        }
    }








    

    
    func getActualStartDate(from userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Date? {
        let validDates = userRecords.keys.filter {
            (userRecords[$0]?.count ?? 0 > 0) && (partnerRecords[$0]?.count ?? 0 > 0)
        }
        return validDates.min() // The earliest date in the streak
    }

    func getActualEndDate(from userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Date? {
        let validDates = userRecords.keys.filter {
            (userRecords[$0]?.count ?? 0 > 0) && (partnerRecords[$0]?.count ?? 0 > 0)
        }
        return validDates.max() // The latest date in the streak
    }



    func calculateStreak(userRecords: [Date: [String]], partnerRecords: [Date: [String]]) -> Int {
        // Create a set of all dates that are present in either user's records
        let allDates = Array(Set(userRecords.keys).union(Set(partnerRecords.keys))).sorted()

        var streakCount = 0
        var currentStreak = 0
        var lastDate: Date?

        // Iterate through dates, checking for consecutive days with records for both users
        for date in allDates {
            // Check if both users have a record for the current date
            let userHasRecord = userRecords[date] != nil
            let partnerHasRecord = partnerRecords[date] != nil

            if userHasRecord && partnerHasRecord {
                // Both users have records for this date
                if let lastDate = lastDate {
                    // Check if the current date is consecutive to the last date
                    if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!) {
                        // Continue the streak
                        currentStreak += 1
                    } else {
                        // Not consecutive, reset streak
                        currentStreak = 1
                    }
                } else {
                    // Start a new streak
                    currentStreak = 1
                }

                // Update the last valid date to the current date
                lastDate = date
            } else {
                // Break the streak if either user is missing a record for this date
                currentStreak = 0
            }

            // Update the maximum streak count
            streakCount = max(streakCount, currentStreak)
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
