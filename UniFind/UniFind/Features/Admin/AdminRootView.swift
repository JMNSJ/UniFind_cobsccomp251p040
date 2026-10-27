
import SwiftUI

struct AdminRootView: View {
    let onLogout: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                AdminDashboardView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out", action: onLogout)
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
                            Button("Sign Out", action: onLogout)
                        }
                    }
            }
            .tabItem {
                Label("Reports", systemImage: "doc.text.magnifyingglass")
            }
        }
        .tint(Color(red: 0.78, green: 0.96, blue: 0.40))
        .preferredColorScheme(.dark)
    }
}
