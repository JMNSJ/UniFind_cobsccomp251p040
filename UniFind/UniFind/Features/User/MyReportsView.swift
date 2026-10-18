
import SwiftUI

struct MyReportsView: View {
    private let reports = [
        ("Black Wallet", "Lost", "Pending"),
        ("Student ID Card", "Found", "Matched"),
        ("Blue Water Bottle", "Lost", "Returned")
    ]

    var body: some View {
        NavigationStack {
            List {
                if reports.isEmpty {
                    ContentUnavailableView(
                        "No Reports Yet",
                        systemImage: "doc.text",
                        description: Text("Your submitted reports will appear here.")
                    )
                } else {
                    ForEach(reports, id: \.0) { report in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(report.0)
                                .font(.headline)

                            HStack {
                                Text(report.1)
                                    .foregroundStyle(
                                        report.1 == "Lost" ? .orange : .green
                                    )

                                Spacer()

                                Text(report.2)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("My Reports")
        }
    }
}

#Preview {
    MyReportsView()
}
