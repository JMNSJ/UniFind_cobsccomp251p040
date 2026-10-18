
import SwiftUI

struct HomeView: View {
    private let recentItems = [
        ("Black Wallet", "Library", "Lost", "wallet.pass.fill"),
        ("Student ID Card", "Main Cafeteria", "Found", "person.text.rectangle"),
        ("Blue Water Bottle", "Lecture Hall", "Lost", "waterbottle.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hello, Student!")
                            .font(.title.bold())

                        Text("Let's help you find what you're looking for.")
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        Text("Search lost and found items")
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Quick Actions")
                        .font(.title3.bold())

                    HStack(spacing: 12) {
                        quickAction(
                            title: "Report Lost",
                            symbol: "exclamationmark.circle",
                            color: .orange
                        )

                        quickAction(
                            title: "Report Found",
                            symbol: "checkmark.circle",
                            color: .green
                        )
                    }

                    Text("Recently Reported")
                        .font(.title3.bold())

                    ForEach(recentItems, id: \.0) { item in
                        HStack(spacing: 14) {
                            Image(systemName: item.3)
                                .font(.title2)
                                .foregroundStyle(.blue)
                                .frame(width: 48, height: 48)
                                .background(.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.0)
                                    .font(.headline)

                                Text(item.1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(item.2)
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    item.2 == "Lost"
                                        ? Color.orange.opacity(0.15)
                                        : Color.green.opacity(0.15)
                                )
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
            }
            .navigationTitle("UniFind")
        }
    }

    private func quickAction(
        title: String,
        symbol: String,
        color: Color
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.title2)

            Text(title)
                .font(.subheadline.bold())
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeView()
}
