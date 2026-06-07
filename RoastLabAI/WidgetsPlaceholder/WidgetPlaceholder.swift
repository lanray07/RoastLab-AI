import Foundation

#if canImport(WidgetKit)
import WidgetKit

struct RoastLabWidgetKinds {
    static let dailyRoast = "com.roastlab.ai.widget.daily-roast"
    static let jokeOfTheDay = "com.roastlab.ai.widget.joke-of-the-day"
    static let roastStreak = "com.roastlab.ai.widget.roast-streak"
    static let randomClapback = "com.roastlab.ai.widget.random-clapback"
}

struct DailyRoastEntry: TimelineEntry {
    let date: Date
    let roast: String
}

struct DailyRoastProviderPlaceholder: TimelineProvider {
    func placeholder(in context: Context) -> DailyRoastEntry {
        DailyRoastEntry(date: Date(), roast: "Your daily roast is warming up.")
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyRoastEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyRoastEntry>) -> Void) {
        let entry = DailyRoastEntry(date: Date(), roast: "Daily roast placeholder.")
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3_600))))
    }
}
#endif
