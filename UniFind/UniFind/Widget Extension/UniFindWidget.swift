
import SwiftUI
import WidgetKit

// MARK: - Widget Entry

struct UniFindWidgetEntry: TimelineEntry {
    let date: Date
    let pendingCount: Int
    let itemName: String
    let message: String
    let location: String
}

// MARK: - Timeline Provider

struct UniFindWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> UniFindWidgetEntry {
        UniFindWidgetEntry(
            date: .now,
            pendingCount: 3,
            itemName: "Student ID Card",
            message: "Urgent: ID card reported lost.",
            location: "University Library"
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (UniFindWidgetEntry) -> Void
    ) {
        completion(sampleEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<UniFindWidgetEntry>) -> Void
    ) {
        let entry = sampleEntry()

        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: .now
        ) ?? Date.now.addingTimeInterval(1800)

        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
        )
    }

    private func sampleEntry() -> UniFindWidgetEntry {
        UniFindWidgetEntry(
            date: .now,
            pendingCount: 3,
            itemName: "Student ID Card",
            message: "Urgent: ID card reported lost.",
            location: "University Library"
        )
    }
}

// MARK: - Admin Priority Requests Widget

struct AdminPriorityRequestsWidget: Widget {

    let kind = "AdminPriorityRequestsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: UniFindWidgetProvider()
        ) { entry in
            VStack(alignment: .leading, spacing: 8) {

                Label(
                    "UniFind Admin",
                    systemImage: "shield.fill"
                )
                .font(.headline)

                Text("\(entry.pendingCount)")
                    .font(.system(size: 34, weight: .bold))

                Text("Pending priority requests")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Text("Open UniFind to review requests.")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            .padding()
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Admin Priority Requests")
        .description("Shows sample pending priority requests.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - High-Priority Alert Widget

struct HighPriorityAlertWidget: Widget {

    let kind = "HighPriorityAlertWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: UniFindWidgetProvider()
        ) { entry in
            VStack(alignment: .leading, spacing: 6) {

                Label(
                    "HIGH PRIORITY",
                    systemImage: "bell.badge.fill"
                )
                .font(.caption.bold())
                .foregroundStyle(.red)

                Text(entry.itemName)
                    .font(.headline)
                    .lineLimit(2)

                Text(entry.message)
                    .font(.caption)
                    .lineLimit(2)

                if !entry.location.isEmpty {
                    Label(
                        entry.location,
                        systemImage: "mappin"
                    )
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text("Example alert")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("UniFind High-Priority Alert")
        .description("Shows a sample important lost-item alert.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
