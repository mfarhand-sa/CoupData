import UIKit
import DGCharts

class CDCareViewController: DemoBaseViewController {
    
    // Scroll view to enable scrolling
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    var moodCounts: [String: Int] = [:] // Add this property to accept the mood data
    private var dailyRecords = CDDataProvider.shared.dailyRecords!

    
    
    // Pie chart view
    var chartView: PieChartView!
    
    // Text view for insights
    private var insightsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Insight"
        
//        
//        let formattedMoodData = dailyRecords.map { (date, records) -> String in
//            let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
//            
//            // Clean the userMoods and partnerMoods by joining and trimming spaces
//            let userMoods = records.userMoods.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
//            let partnerMoods = records.partnerMoods.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            return "Date: \(formattedDate), Your Moods: \(userMoods), Partner's Moods: \(partnerMoods)"
//        }.joined(separator: "\n")
//        
//        FirebaseManager.shared.getInsightsFromOpenRouter(formattedMoodData: formattedMoodData) { insightResult in
//            if let insights = insightResult {
//                // Handle the insights received
//                print("Insights: \(insights)")
//                CDDataProvider.shared.insights = insights
//                
//                DispatchQueue.main.async {
//                    // Example insights data
//                    let insights = CDDataProvider.shared.insights!
//                    self.displayInsights(insights: insights)
//
//                }
//                
//            } else {
//                print("Failed to receive insights.")
//            }
//        }
        
        
        // Set up the UI components
        setupScrollView()
        setupChartView()
        self.setup(pieChartView: chartView)
        
        chartView.delegate = self
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        //        chartView.legend = l
        
        // entry label styling
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        
        
        self.updateChartData()
        
        
        setupTextView()
        
        
        
        
        
        
//        // Example insights data
        if let insights = CDDataProvider.shared.insights {
            displayInsights(insights: insights)
        }
    }
    
    // Set up the scroll view and content view
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Constraints for the scroll view
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Important for scrolling
        ])
    }
    
    // Set up the pie chart view
    private func setupChartView() {
        chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chartView)
        chartView.backgroundColor = .white
        contentView.backgroundColor = .white
        chartView.drawEntryLabelsEnabled = true

        
        // Constraints for the pie chart view
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -40),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.2)
            //chartView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    // Set up the text view
    private func setupTextView() {
        insightsTextView = UITextView()
        insightsTextView.isEditable = false
        insightsTextView.isScrollEnabled = false // Set to false to avoid conflict with scrollView
        insightsTextView.font = UIFont(name: "Poppins-Regular", size: 16)
        insightsTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(insightsTextView)
        
        // Constraints for the text view
        NSLayoutConstraint.activate([
            insightsTextView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -40),
            insightsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            insightsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            insightsTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    
    // Display formatted insights in the text view
    
    private func displayInsights(insights: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        // Attributes for the main text
        let mainFont = UIFont(name: "Poppins-Regular", size: 16)!
        let attributes: [NSAttributedString.Key: Any] = [
            .font: mainFont,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSMutableAttributedString(string: insights, attributes: attributes)
        
        // Keywords to highlight (e.g., moods)
        let moodKeywords = ["Anxiety", "Stress", "Love", "Calm", "Anxious", "Loved"]
        let moodColors: [String: UIColor] = [
            "Anxiety": .orange,
            "Stress": .orange,
            "Love": .systemPink,
            "Calm": .cyan,
            "Anxious": .orange,
            "Loved": .systemPink
        ]
        
        for mood in moodKeywords {
            // Case-insensitive search and whole word matching
            let regex = try! NSRegularExpression(pattern: "\\b\(mood)\\b", options: [.caseInsensitive])
            let matches = regex.matches(in: attributedText.string, options: [], range: NSRange(location: 0, length: attributedText.length))
            
            for match in matches {
                // Apply bold font
                attributedText.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16)!, range: match.range)
                // Apply color
                if let color = moodColors[mood] {
                    attributedText.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            }
        }
        
        // Highlight dates (in format: MM/dd/yy or other patterns)
        let datePattern = "\\b\\d{1,2}/\\d{1,2}/\\d{2}\\b"
        let dateRegex = try! NSRegularExpression(pattern: datePattern)
        let dateMatches = dateRegex.matches(in: attributedText.string, options: [], range: NSRange(location: 0, length: attributedText.length))
        
        for match in dateMatches {
            // Apply color and bold formatting to dates
            attributedText.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16)!, range: match.range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.purple, range: match.range)
        }
        
        insightsTextView.attributedText = attributedText
    }

    
    
    
    func setDataCount(_ count: Int, range: UInt32) {
        
        let totalCount = moodCounts.values.reduce(0, +)
        let entries = moodCounts.map { (mood, count) -> PieChartDataEntry in
            let percentage = Double(count) / Double(totalCount) * 100
            return PieChartDataEntry(value: percentage, label: mood)
        }
        
        // Create the PieChartDataSet
        let set = PieChartDataSet(entries: entries, label: "Mood Distribution")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        // Set colors for the pie chart
        set.colors = ChartColorTemplates.vordiplom()
        + ChartColorTemplates.joyful()
        + ChartColorTemplates.colorful()
        + ChartColorTemplates.liberty()
        + ChartColorTemplates.pastel()
        + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        // Create the PieChartData
        let data = PieChartData(dataSet: set)
        
        // Format the data values
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(4), range: UInt32(100))
    }
    
    
    
}

