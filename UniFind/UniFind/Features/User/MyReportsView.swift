
import SwiftUI

struct MyReportsView: View {
    @ObservedObject private var reportStore = ReportStore.shared
    @State private var reportToEdit: LostFoundItem?

    var body: some View {
        NavigationStack {
            Group {
                if reportStore.isLoading && reportStore.reports.isEmpty {
                    ProgressView("Loading your reports...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if reportStore.reports.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(reportStore.reports) { report in
                            reportRow(report)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Reports")
            .sheet(item: $reportToEdit) { report in
                NavigationStack {
                    EditReportView(report: report)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("No Reports Yet")
                .font(.title2.bold())

            Text("Items you report as lost or found will appear here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func reportRow(_ report: LostFoundItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let image = report.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.12))
                }
            }
            .frame(width: 82, height: 82)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(report.itemName)
                    .font(.headline)

                Text(report.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(
                    report.location.isEmpty
                        ? "Location not provided"
                        : report.location,
                    systemImage: "mappin.and.ellipse"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

                Text(
                    "\(report.reportType) • \(report.dateReported.formatted(date: .abbreviated, time: .shortened))"
                )
                .font(.caption)
                .foregroundStyle(
                    report.reportType == "Lost" ? .red : .green
                )

                Text("Status: \(report.status)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Button {
                    reportToEdit = report
                } label: {
                    Label("Edit Report", systemImage: "pencil")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .padding(.top, 3)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    MyReportsView()
}
