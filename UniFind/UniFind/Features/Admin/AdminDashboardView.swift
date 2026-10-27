
import SwiftUI
import FirebaseFirestore

struct AdminDashboardView: View {

    @StateObject private var viewModel = AdminViewModel()
    @State private var requestListener: ListenerRegistration?
    @State private var checkingAccess = true

    var body: some View {
        Group {
            if checkingAccess || viewModel.isLoading {
                ZStack {
                    UniFindBackground()

                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(UniFindStyle.indigo)
                            .scaleEffect(1.2)

                        Text("Checking admin access...")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(UniFindStyle.muted)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if !viewModel.isAdmin {
                ZStack {
                    UniFindBackground()

                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(UniFindStyle.indigo)
                            .frame(width: 90, height: 90)
                            .background(UniFindStyle.paleIndigo)
                            .clipShape(RoundedRectangle(cornerRadius: 28))

                        Text("Admin Access Required")
                            .font(.title2.bold())
                            .foregroundStyle(UniFindStyle.ink)

                        Text(
                            viewModel.errorMessage ??
                            "This account is not authorised to access the admin dashboard."
                        )
                        .font(.subheadline)
                        .foregroundStyle(UniFindStyle.muted)
                        .multilineTextAlignment(.center)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                    .uniGlassCard()
                    .padding(24)
                }

            } else {
                dashboardContent
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
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
        .preferredColorScheme(.light)
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        ZStack {
            UniFindBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {

                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ADMIN PORTAL")
                                    .font(.caption.bold())
                                    .tracking(2)
                                    .foregroundStyle(UniFindStyle.indigo)

                                Text("Admin Overview")
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(UniFindStyle.ink)
                            }

                            Spacer()

                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(UniFindStyle.indigo)
                                .frame(width: 60, height: 60)
                                .background(UniFindStyle.paleIndigo)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 21)
                                )
                        }

                        Text("Monitor UniFind activity and review reports.")
                            .font(.subheadline)
                            .foregroundStyle(UniFindStyle.muted)
                    }
                    .padding(.top, 12)

                    // Statistics
                    VStack(alignment: .leading, spacing: 14) {
                        sectionHeading(
                            "Overview",
                            subtitle: "A summary of university activity"
                        )

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 14)
                            ],
                            spacing: 14
                        ) {
                            statisticCard(
                                title: "Total Reports",
                                count: viewModel.statistics.total,
                                symbol: "doc.text.fill",
                                color: UniFindStyle.indigo,
                                background: UniFindStyle.paleIndigo
                            )

                            statisticCard(
                                title: "Pending Reports",
                                count: viewModel.statistics.pending,
                                symbol: "clock.fill",
                                color: .orange,
                                background: Color.orange.opacity(0.12)
                            )

                            statisticCard(
                                title: "Lost Items",
                                count: viewModel.statistics.lost,
                                symbol: "magnifyingglass",
                                color: .purple,
                                background: Color.purple.opacity(0.10)
                            )

                            statisticCard(
                                title: "Found Items",
                                count: viewModel.statistics.found,
                                symbol: "checkmark.circle.fill",
                                color: UniFindStyle.teal,
                                background: UniFindStyle.paleTeal
                            )

                            statisticCard(
                                title: "Urgent Reviews",
                                count: viewModel.statistics.urgent,
                                symbol: "bell.badge.fill",
                                color: .pink,
                                background: Color.pink.opacity(0.10)
                            )

                            statisticCard(
                                title: "Priority Requests",
                                count: viewModel.pendingPriorityCount,
                                symbol: "exclamationmark.bell.fill",
                                color: .orange,
                                background: Color.orange.opacity(0.12)
                            )
                        }
                    }

                    // Error Message
                    if let error = viewModel.errorMessage {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)

                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(UniFindStyle.ink)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Priority Alert Management
                    VStack(alignment: .leading, spacing: 14) {
                        sectionHeading(
                            "Priority Alert Management",
                            subtitle: "Review requests and manage alerts"
                        )

                        NavigationLink {
                            PriorityRequestsView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.orange)
                                    .frame(width: 52, height: 52)
                                    .background(
                                        Color.orange.opacity(0.12)
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 17)
                                    )

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Review Priority Requests")
                                        .font(.headline)
                                        .foregroundStyle(UniFindStyle.ink)

                                    Text(
                                        "\(viewModel.pendingPriorityCount) waiting for review"
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(UniFindStyle.muted)
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(UniFindStyle.muted)
                            }
                            .padding(17)
                            .uniGlassCard()
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            AdminAlertsView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "megaphone.fill")
                                    .font(.system(size: 21, weight: .semibold))
                                    .foregroundStyle(UniFindStyle.teal)
                                    .frame(width: 52, height: 52)
                                    .background(UniFindStyle.paleTeal)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 17)
                                    )

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Manage Published Alerts")
                                        .font(.headline)
                                        .foregroundStyle(UniFindStyle.ink)

                                    Text("Manage approved urgent alerts")
                                        .font(.subheadline)
                                        .foregroundStyle(UniFindStyle.muted)
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(UniFindStyle.muted)
                            }
                            .padding(17)
                            .uniGlassCard()
                        }
                        .buttonStyle(.plain)
                    }

                    // Responsibilities
                    VStack(alignment: .leading, spacing: 14) {
                        sectionHeading(
                            "Admin Responsibilities",
                            subtitle: "Keep UniFind organised and reliable"
                        )

                        VStack(spacing: 18) {
                            responsibilityRow(
                                title: "Review submitted reports",
                                subtitle: "Check lost and found item information.",
                                symbol: "doc.text.magnifyingglass",
                                color: UniFindStyle.indigo
                            )

                            Divider()
                                .overlay(Color.white.opacity(0.8))

                            responsibilityRow(
                                title: "Approve or reject requests",
                                subtitle: "Review priority requests before broadcasting.",
                                symbol: "bell.badge.fill",
                                color: .orange
                            )

                            Divider()
                                .overlay(Color.white.opacity(0.8))

                            responsibilityRow(
                                title: "Track item return status",
                                subtitle: "Help keep report statuses up to date.",
                                symbol: "checkmark.circle.fill",
                                color: UniFindStyle.teal
                            )
                        }
                        .padding(18)
                        .uniGlassCard()
                    }

                    Text("UniFind • Administration")
                        .font(.caption)
                        .foregroundStyle(UniFindStyle.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 2)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Section Heading

    private func sectionHeading(
        _ title: String,
        subtitle: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(UniFindStyle.ink)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(UniFindStyle.muted)
        }
    }

    // MARK: - Statistic Card

    private func statisticCard(
        title: String,
        count: Int,
        symbol: String,
        color: Color,
        background: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: symbol)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(background)
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.caption.bold())
                    .foregroundStyle(UniFindStyle.muted)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("\(count)")
                    .font(.system(size: 29, weight: .bold))
                    .foregroundStyle(UniFindStyle.ink)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(UniFindStyle.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .uniGlassCard()
    }

    // MARK: - Responsibility Row

    private func responsibilityRow(
        title: String,
        subtitle: String,
        symbol: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(UniFindStyle.ink)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(UniFindStyle.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Priority Request Listener

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

