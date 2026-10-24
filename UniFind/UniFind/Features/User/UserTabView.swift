
import SwiftUI

struct UserTabView: View {

    let onLogout: () -> Void

    private let accentColor = Color(
        red: 0.78,
        green: 0.96,
        blue: 0.40
    )

    var body: some View {
        TabView {

            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            ReportItemView()
                .tabItem {
                    Label("Report", systemImage: "plus.circle.fill")
                }

            MyReportsView()
                .tabItem {
                    Label("My Reports", systemImage: "doc.text.fill")
                }

            ProfileView(onLogout: onLogout)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(accentColor)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    UserTabView(onLogout: {})
}

