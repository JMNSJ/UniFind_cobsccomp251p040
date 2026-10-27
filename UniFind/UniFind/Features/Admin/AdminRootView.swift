
import SwiftUI

struct AdminRootView: View {
    let onLogout: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                AdminDashboardView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: onLogout) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(UniFindStyle.indigo)
                            }
                            .accessibilityLabel("Sign Out")
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                AdminReportsView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: onLogout) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(UniFindStyle.indigo)
                            }
                            .accessibilityLabel("Sign Out")
                        }
                    }
            }
            .tabItem {
                Label("Reports", systemImage: "doc.text.magnifyingglass")
            }
        }
        .tint(UniFindStyle.indigo)
        .preferredColorScheme(.light)
    }
}
