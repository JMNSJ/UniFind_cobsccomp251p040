
import SwiftUI

struct HomeView: View {
    var onSelectTab: (Int) -> Void = { _ in }

    private let recentItems = [
        ("Black Wallet", "Library", "Lost", "wallet.pass.fill"),
        ("Student ID Card", "Main Cafeteria", "Found", "person.text.rectangle"),
        ("Blue Water Bottle", "Lecture Hall", "Lost", "waterbottle.fill")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                UniFindBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("YOUR CAMPUS, CONNECTED")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1.8)
                                    .foregroundStyle(UniFindStyle.indigo)

                                Text("Hello, Student!")
                                    .font(.system(size: 29, weight: .bold, design: .rounded))
                                    .foregroundStyle(UniFindStyle.ink)

                                Text("Let's help you find what matters.")
                                    .font(.subheadline)
                                    .foregroundStyle(UniFindStyle.muted)
                            }

                            Spacer()

                            Image(systemName: "sparkles")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(UniFindStyle.teal)
                                .frame(width: 52, height: 52)
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white, lineWidth: 1)
                                }
                        }

                        Button {
                            onSelectTab(1)
                        } label: {
                            HStack(spacing: 13) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(UniFindStyle.indigo)

                                Text("Search lost and found items")
                                    .font(.subheadline)
                                    .foregroundStyle(UniFindStyle.muted)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(UniFindStyle.indigo)
                            }
                            .padding(18)
                            .uniGlassCard(cornerRadius: 19)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 14) {
                            sectionHeading("Quick Actions", subtitle: "What would you like to do?")

                            HStack(spacing: 14) {
                                quickAction(
                                    title: "Report Lost",
                                    subtitle: "Missing an item?",
                                    symbol: "magnifyingglass",
                                    color: UniFindStyle.indigo
                                ) {
                                    onSelectTab(2)
                                }

                                quickAction(
                                    title: "Report Found",
                                    subtitle: "Found something?",
                                    symbol: "hand.raised.fill",
                                    color: UniFindStyle.teal
                                ) {
                                    onSelectTab(2)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                sectionHeading(
                                    "Recently Reported",
                                    subtitle: "A glimpse of campus activity"
                                )

                                Spacer()

                                Button("View all") {
                                    onSelectTab(1)
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(UniFindStyle.indigo)
                            }

                            ForEach(recentItems, id: \.0) { item in
                                HStack(spacing: 14) {
                                    Image(systemName: item.3)
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundStyle(
                                            item.2 == "Lost"
                                            ? UniFindStyle.indigo
                                            : UniFindStyle.teal
                                        )
                                        .frame(width: 54, height: 54)
                                        .background(
                                            item.2 == "Lost"
                                            ? UniFindStyle.paleIndigo
                                            : UniFindStyle.paleTeal
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 17))

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.0)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(UniFindStyle.ink)

                                        Label(item.1, systemImage: "mappin.and.ellipse")
                                            .font(.caption)
                                            .foregroundStyle(UniFindStyle.muted)
                                    }

                                    Spacer(minLength: 4)

                                    Text(item.2)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(
                                            item.2 == "Lost"
                                            ? UniFindStyle.indigo
                                            : Color(red: 0.06, green: 0.52, blue: 0.40)
                                        )
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 7)
                                        .background(
                                            item.2 == "Lost"
                                            ? UniFindStyle.paleIndigo
                                            : UniFindStyle.paleTeal
                                        )
                                        .clipShape(Capsule())
                                }
                                .padding(14)
                                .uniGlassCard(cornerRadius: 20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(UniFindStyle.ink)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(UniFindStyle.muted)
        }
    }

    private func quickAction(
        title: String,
        subtitle: String,
        symbol: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 45, height: 45)
                    .background(color.opacity(0.11))
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(UniFindStyle.ink)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(UniFindStyle.muted)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .uniGlassCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
