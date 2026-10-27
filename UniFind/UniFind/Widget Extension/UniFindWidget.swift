
import SwiftUI
import WidgetKit

private let appGroupID = "group.com.example.UniFind"

struct UniFindWidgetEntry: TimelineEntry {
    let date: Date
    let pendingCount: Int
    let itemName: String
    let message: String
    let location: String
}

struct UniFindWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> UniFindWidgetEntry {
        UniFindWidgetEntry(
            date: .now,
            pendingCount: 2,
            itemName: "Student ID Card",
            message: "Urgent: ID card reported lost.",
            location: "University Library"
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (UniFindWidgetEntry) -> Void
    ) {
        completion(makeEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<UniFindWidgetEntry>) -> Void
    ) {
        let entry = makeEntry()

        // iOS controls when the next refresh actually occurs.
        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: .now
        ) ?? .now.addingTimeInterval(1800)

        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )
        )
    }

    private func makeEntry() -> UniFindWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupID)

        let count = defaults?.integer(
            forKey: "adminPendingRequestCount"
        ) ?? 0

        let alert = defaults?.dictionary(
            forKey: "latestPriorityAlert"
        ) as? [String: String] ?? [:]

        return UniFindWidgetEntry(
            date: .now,
            pendingCount: count,
            itemName: alert["itemName"] ?? "No active alerts",
            message: alert["message"] ?? "Important alerts will appear here.",
            location: alert["location"] ?? ""
        )
    }
}

// MARK: Widget 1 — Admin pending requests

struct AdminPriorityRequestsWidget: Widget {
    let kind = "AdminPriorityRequestsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: UniFindWidgetProvider()
        ) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Label("UniFind Admin", systemImage: "shield.fill")
                    .font(.headline)

                Text("\(entry.pendingCount)")
                    .font(.system(size: 34, weight: .bold))

                Text("Pending priority requests")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Link(
                    "Open requests",
                    destination: URL(string: "unifind://admin/priority-requests")!
                )
                .font(.caption.bold())
            }
            .padding()
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Admin Priority Requests")
        .description("Shows the number of pending priority alert requests.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: Widget 2 — Shared high-priority alert

struct HighPriorityAlertWidget: Widget {
    let kind = "HighPriorityAlertWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: UniFindWidgetProvider()
        ) { entry in
            VStack(alignment: .leading, spacing: 6) {
                Label("HIGH PRIORITY", systemImage: "bell.badge.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.red)

                Text(entry.itemName)
                    .font(.headline)
                    .lineLimit(2)

                Text(entry.message)
                    .font(.caption)
                    .lineLimit(2)

                if !entry.location.isEmpty {
                    Label(entry.location, systemImage: "mappin")
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Link(
                    "View alert",
                    destination: URL(string: "unifind://priority-alerts")!
                )
                .font(.caption.bold())
            }
            .padding()
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("UniFind High-Priority Alert")
        .description("Displays the latest approved important lost-item alert.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
