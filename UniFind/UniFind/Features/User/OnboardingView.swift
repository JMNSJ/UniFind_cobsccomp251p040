
import SwiftUI

struct OnboardingView: View {

    let onGetStarted: () -> Void

    private let backgroundColor =
        Color(red: 0.055, green: 0.075, blue: 0.14)

    private let limeColor =
        Color(red: 0.78, green: 0.96, blue: 0.40)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main dark background.
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.14, blue: 0.25),
                        backgroundColor,
                        Color(red: 0.12, green: 0.10, blue: 0.23)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Decorative background shapes.
                Circle()
                    .fill(
                        Color(red: 0.40, green: 0.35, blue: 0.85)
                            .opacity(0.25)
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 150, y: -geometry.size.height * 0.30)

                Circle()
                    .fill(limeColor.opacity(0.12))
                    .frame(width: 230, height: 230)
                    .blur(radius: 70)
                    .offset(x: -150, y: geometry.size.height * 0.20)

                VStack(spacing: 0) {

                    // Brand.
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(limeColor)
                                .frame(width: 46, height: 46)

                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundStyle(backgroundColor)
                        }

                        Text("UniFind")
                            .font(.system(size: 27, weight: .bold))
                            .tracking(-0.8)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("CAMPUS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(limeColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 14)

                    Spacer(minLength: 24)

                    // Main illustration.
                    ZStack {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.035)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(
                                        Color.white.opacity(0.12),
                                        lineWidth: 1
                                    )
                            }

                        Circle()
                            .fill(limeColor.opacity(0.12))
                            .frame(width: 190, height: 190)

                        Circle()
                            .stroke(
                                Color.white.opacity(0.13),
                                style: StrokeStyle(
                                    lineWidth: 1,
                                    dash: [5, 7]
                                )
                            )
                            .frame(width: 235, height: 235)

                        Image(systemName: "backpack.fill")
                            .font(.system(size: 105, weight: .regular))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        .white,
                                        Color(red: 0.72, green: 0.77, blue: 0.92)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 20,
                                x: 0,
                                y: 15
                            )

                        // Floating location badge.
                        floatingBadge(
                            symbol: "location.fill",
                            color: limeColor
                        )
                        .offset(x: 100, y: -85)

                        // Floating lost-item badge.
                        floatingBadge(
                            symbol: "key.fill",
                            color: Color(red: 1.0, green: 0.69, blue: 0.48)
                        )
                        .offset(x: -105, y: 65)

                        // Match badge.
                        HStack(spacing: 7) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(limeColor)

                            Text("Ready to reconnect")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .background(backgroundColor.opacity(0.85))
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(
                                    Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        }
                        .offset(y: 125)
                    }
                    .frame(height: min(geometry.size.height * 0.34, 285))

                    Spacer(minLength: 36)

                    // Main message.
                    VStack(alignment: .leading, spacing: 18) {
                        Text("LOST SOMETHING?")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(3)
                            .foregroundStyle(limeColor)

                        (
                            Text("Find what matters.\n")
                                .foregroundColor(.white)
                            +
                            Text("Bring it ")
                                .foregroundColor(.white)
                            +
                            Text("back.")
                                .foregroundColor(limeColor)
                        )
                        .font(.system(size: 38, weight: .bold))
                        .tracking(-1.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.75)

                        Text(
                            "Report lost items, discover possible matches, " +
                            "and help belongings find their way home."
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(
                            Color.white.opacity(0.67)
                        )
                        .lineSpacing(5)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 28)

                    // Feature highlights.
                    HStack(spacing: 10) {
                        featurePill(
                            symbol: "magnifyingglass",
                            title: "Discover"
                        )

                        featurePill(
                            symbol: "camera.fill",
                            title: "Report"
                        )

                        featurePill(
                            symbol: "arrow.trianglehead.2.clockwise",
                            title: "Reconnect"
                        )
                    }

                    Spacer(minLength: 25)

                    // Primary action.
                    Button(action: onGetStarted) {
                        HStack {
                            Spacer()

                            Text("Get Started")
                                .font(.system(size: 16, weight: .bold))

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(backgroundColor)
                        .padding(.horizontal, 22)
                        .frame(height: 58)
                        .background(limeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    Text("YOUR CAMPUS. YOUR COMMUNITY.")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.42))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 26)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Floating badges

    private func floatingBadge(
        symbol: String,
        color: Color
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 17)
                .fill(backgroundColor)
                .frame(width: 52, height: 52)

            RoundedRectangle(cornerRadius: 17)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .frame(width: 52, height: 52)

            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
        }
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
    }

    // MARK: - Feature pills

    private func featurePill(
        symbol: String,
        title: String
    ) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(limeColor)

            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(.white.opacity(0.065))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}

