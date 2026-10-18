
import SwiftUI

struct UserTabView: View {
    let onLogout: () -> Void

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            ReportItemView()
                .tabItem {
                    Label("Report", systemImage: "plus.circle")
                }

            MyReportsView()
                .tabItem {
                    Label("My Reports", systemImage: "doc.text")
                }

            ProfileView(onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    UserTabView(onLogout: {})
}
