
import SwiftUI

struct UserTabView: View {
    let onLogout: () -> Void

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(onSelectTab: { selectedTab = $0 })
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            ReportItemView()
                .tabItem {
                    Label("Report", systemImage: "plus.circle.fill")
                }
                .tag(2)

            MyReportsView()
                .tabItem {
                    Label("My Reports", systemImage: "doc.text.fill")
                }
                .tag(3)

            ProfileView(onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
        .tint(UniFindStyle.indigo)
        .preferredColorScheme(.light)
    }
}

#Preview {
    UserTabView(onLogout: {})
}
