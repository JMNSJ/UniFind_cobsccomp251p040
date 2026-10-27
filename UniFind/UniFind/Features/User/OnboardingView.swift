
import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let eyebrow: String
    let title: String
    let highlight: String
    let description: String
    let symbol: String
    let tint: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "WELCOME TO UNIFIND",
            title: "Find what",
            highlight: "matters.",
            description: "A smarter way to reconnect students with lost belongings across your university.",
            symbol: "magnifyingglass",
            tint: UniFindStyle.indigo
        ),
        OnboardingPage(
            id: 1,
            eyebrow: "REPORT WITH EASE",
            title: "Lost or found?",
            highlight: "Report it.",
            description: "Share item details, descriptions and photos to help your campus community find missing belongings.",
            symbol: "camera.viewfinder",
            tint: UniFindStyle.teal
        ),
        OnboardingPage(
            id: 2,
            eyebrow: "RECONNECT YOUR CAMPUS",
            title: "Every item",
            highlight: "has a way home.",
            description: "Discover reports, check possible matches and help belongings return to their owners.",
            symbol: "heart.circle.fill",
            tint: Color(red: 0.88, green: 0.47, blue: 0.58)
        )
    ]
}

struct OnboardingView: View {
    let onGetStarted: () -> Void

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            UniFindBackground()

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(UniFindStyle.indigo)
                            .frame(width: 42, height: 42)

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text("UniFind")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .tracking(-0.7)
                        .foregroundStyle(UniFindStyle.ink)

                    Spacer()

                    Button("Skip") {
                        onGetStarted()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(UniFindStyle.indigo)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(OnboardingPage.all) { page in
                        pageContent(page)
                            .tag(page.id)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                HStack(spacing: 8) {
                    ForEach(OnboardingPage.all) { page in
                        Capsule()
                            .fill(
                                currentPage == page.id
                                ? UniFindStyle.indigo
                                : UniFindStyle.indigo.opacity(0.18)
                            )
                            .frame(
                                width: currentPage == page.id ? 26 : 7,
                                height: 7
                            )
                    }
                }
                .padding(.bottom, 24)

                HStack(spacing: 12) {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(UniFindStyle.indigo)
                                .frame(width: 58, height: 56)
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 17)
                                        .stroke(Color.white, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        if currentPage < OnboardingPage.all.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(currentPage == OnboardingPage.all.count - 1 ? "Get Started" : "Continue")
                            Spacer()
                            Image(systemName: currentPage == OnboardingPage.all.count - 1 ? "checkmark" : "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [UniFindStyle.indigo, UniFindStyle.teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                        .shadow(color: UniFindStyle.indigo.opacity(0.18), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)

                Text("YOUR CAMPUS. YOUR COMMUNITY.")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(UniFindStyle.muted)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
            }
        }
        .preferredColorScheme(.light)
    }

    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            ZStack {
                RoundedRectangle(cornerRadius: 34)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 34)
                            .stroke(Color.white.opacity(0.9), lineWidth: 1)
                    }

                Circle()
                    .fill(page.tint.opacity(0.12))
                    .frame(width: 190, height: 190)

                Circle()
                    .stroke(page.tint.opacity(0.18), lineWidth: 1)
                    .frame(width: 225, height: 225)

                Image(systemName: page.symbol)
                    .font(.system(size: 82, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.tint, UniFindStyle.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 31))
                    .foregroundStyle(UniFindStyle.teal)
                    .background(Circle().fill(.white))
                    .offset(x: 91, y: -81)
            }
            .frame(height: 255)
            .uniGlassCard(cornerRadius: 34)

            Spacer(minLength: 32)

            VStack(alignment: .leading, spacing: 16) {
                Text(page.eyebrow)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(page.tint)

                VStack(alignment: .leading, spacing: 1) {
                    Text(page.title)
                        .foregroundStyle(UniFindStyle.ink)

                    Text(page.highlight)
                        .foregroundStyle(page.tint)
                }
                .font(.system(size: 37, weight: .bold, design: .rounded))
                .tracking(-1.1)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)

                Text(page.description)
                    .font(.system(size: 15))
                    .foregroundStyle(UniFindStyle.muted)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 28)
        }
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
