import Foundation
import Lottie
import HorizonCalendar

class StreakViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var label: UILabel!
    public var viewModel: PartnerViewModel!
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
        longPressGesture.minimumPressDuration = 0.5
        
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
                }
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Stop the animation and remove it when the user lifts their finger
            if let heartAnimationView = heartAnimationView {
                print("Long press ended, animation stopped")
                heartAnimationView.stop() // Stop the animation
                heartAnimationView.removeFromSuperview() // Remove from the view hierarchy
                self.heartAnimationView = nil // Clear the reference
            }
        }
    }




    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        guard CDDataProvider.shared.partnerID != nil else { return }
        
//        viewModel.loadUserAndPartnerData(userID: UserManager.shared.currentUserID!, partnerID: UserManager.shared.partnerUserID!) { streakCount, startDate, endDate, error in
//            
//            if let streakCount = streakCount, let startDate = startDate, let endDate = endDate {
//                print("The current streak is: \(streakCount) days")
//                
//                print("Streak: \(streakCount)")
//                print("Start Date: \(startDate)")
//                print("End Date: \(endDate)")
//                
//                let fullText = "\(streakCount) days and counting—your bond with your partner keeps growing!"
//                let attributedString = NSMutableAttributedString(string: fullText)
//                let boldRange = (fullText as NSString).range(of: "\(streakCount) days")
//                
//                attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 24)!, range: boldRange)
//                self.label.attributedText = attributedString
//                
//                self.calendarView = CalendarView(initialContent: self.makeContent(startDate: startDate, endDate: endDate))
//                
//                // Day selection handler to refresh content when a date is selected
//                self.calendarView.daySelectionHandler = nil
//                 self.streakCalendarView.addSubview(self.calendarView)
//                self.calendarView.translatesAutoresizingMaskIntoConstraints = false
//                
//                NSLayoutConstraint.activate([
//                    self.calendarView.leadingAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.leadingAnchor),
//                    self.calendarView.trailingAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.trailingAnchor),
//                    self.calendarView.topAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.topAnchor),
//                    self.calendarView.bottomAnchor.constraint(equalTo: self.streakCalendarView.layoutMarginsGuide.bottomAnchor),
//                ])
//                
//                self.calendarView.scroll(
//                    toMonthContaining: endDate,
//                    scrollPosition: .centered, // or .firstFullyVisiblePosition
//                    animated: false // Set to true if you want to animate the scroll
//                )
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        }
        
        viewModel.loadUserAndPartnerData(userID: UserManager.shared.currentUserID!, partnerID: UserManager.shared.partnerUserID!) { streakCount, startDate, endDate, error in
            
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
                        self.calendarView.leadingAnchor.constraint(equalTo: self.streakCalendarView.safeAreaLayoutGuide.leadingAnchor),
                        self.calendarView.trailingAnchor.constraint(equalTo: self.streakCalendarView.safeAreaLayoutGuide.trailingAnchor),
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
    
}

import HorizonCalendar
import UIKit

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
        label?.font = UIFont.systemFont(ofSize: 16)
        
        
        // Set the background color based on the custom isHighlighted property
        view.backgroundColor = view.isHighlighted ? .accent : UIColor.clear
    }
}

// Custom UIView that includes a highlight property
class HighlightableDayView: UIView {
    var isHighlighted: Bool = false
}
