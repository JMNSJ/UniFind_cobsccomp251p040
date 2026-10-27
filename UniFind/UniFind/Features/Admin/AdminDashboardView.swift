
import SwiftUI
import FirebaseFirestore

struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminViewModel()
    @State private var requestListener: ListenerRegistration?
    @State private var checkingAccess = true

    var body: some View {
        Group {
            if checkingAccess || viewModel.isLoading {
                ProgressView("Checking admin access...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if !viewModel.isAdmin {
                ContentUnavailableView(
                    "Admin Access Required",
                    systemImage: "lock.shield",
                    description: Text(
                        viewModel.errorMessage ??
                        "This account is not authorised to access the admin dashboard."
                    )
                )

            } else {
                dashboardContent
            }
        }
        .navigationTitle("Dashboard")
        .task {
            checkingAccess = true

            let allowed = await viewModel.checkAdminAccess()

            if allowed {
                await viewModel.loadStatistics()
                startPriorityRequestListener()
            }

            checkingAccess = false
        }
        .refreshable {
            guard viewModel.isAdmin else { return }
            await viewModel.loadStatistics()
        }
        .onDisappear {
            requestListener?.remove()
            requestListener = nil
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Admin Overview")
                        .font(.largeTitle.bold())

                    Text("Monitor UniFind activity and review reports.")
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    statisticCard(
                        title: "Total Reports",
                        count: viewModel.statistics.total,
                        symbol: "doc.text"
                    )

                    statisticCard(
                        title: "Pending Reports",
                        count: viewModel.statistics.pending,
                        symbol: "clock"
                    )

                    statisticCard(
                        title: "Lost Items",
                        count: viewModel.statistics.lost,
                        symbol: "magnifyingglass"
                    )

                    statisticCard(
                        title: "Found Items",
                        count: viewModel.statistics.found,
                        symbol: "checkmark.circle"
                    )

                    statisticCard(
                        title: "Urgent Reviews",
                        count: viewModel.statistics.urgent,
                        symbol: "bell.badge"
                    )

                    statisticCard(
                        title: "Priority Requests",
                        count: viewModel.pendingPriorityCount,
                        symbol: "exclamationmark.bell.fill"
                    )
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Text("Priority Alert Management")
                    .font(.title3.bold())

                NavigationLink {
                    PriorityRequestsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .font(.title2)
                            .foregroundStyle(.red)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Review Priority Requests")
                                .font(.headline)

                            Text(
                                "\(viewModel.pendingPriorityCount) waiting for review"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    AdminAlertsView()
                } label: {
                    Label(
                        "Manage Published Alerts",
                        systemImage: "megaphone.fill"
                    )
                }

                Text("Admin Responsibilities")
                    .font(.title3.bold())

                Label(
                    "Review submitted reports",
                    systemImage: "doc.text.magnifyingglass"
                )

                Label(
                    "Approve or reject priority requests",
                    systemImage: "bell.badge"
                )

                Label(
                    "Track item return status",
                    systemImage: "checkmark.circle"
                )
            }
            .padding()
        }
    }

    private func statisticCard(
        title: String,
        count: Int,
        symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)

            Text("\(count)")
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func startPriorityRequestListener() {
        guard requestListener == nil else { return }

        requestListener = PriorityAlertService.shared
            .listenForPendingRequests { requests in
                Task { @MainActor in
                    viewModel.updatePendingPriorityCount(requests.count)
                }
            } onError: { error in
                Task { @MainActor in
                    viewModel.errorMessage =
                        "Could not load priority requests: " +
                        error.localizedDescription
                }
            }
    }
}
