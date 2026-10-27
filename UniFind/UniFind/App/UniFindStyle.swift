
import SwiftUI

enum UniFindStyle {
    static let background = Color(red: 0.95, green: 0.97, blue: 0.99)
    static let indigo = Color(red: 0.31, green: 0.32, blue: 0.82)
    static let teal = Color(red: 0.08, green: 0.65, blue: 0.62)
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.27)
    static let muted = Color(red: 0.43, green: 0.48, blue: 0.58)
    static let paleIndigo = Color(red: 0.91, green: 0.92, blue: 1.00)
    static let paleTeal = Color(red: 0.87, green: 0.97, blue: 0.95)
}

struct UniFindGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.48))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
            }
            .shadow(
                color: UniFindStyle.indigo.opacity(0.07),
                radius: 18,
                x: 0,
                y: 8
            )
    }
}

extension View {
    func uniGlassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(UniFindGlassCard(cornerRadius: cornerRadius))
    }
}

struct UniFindBackground: View {
    var body: some View {
        ZStack {
            UniFindStyle.background

            LinearGradient(
                colors: [
                    UniFindStyle.paleIndigo.opacity(0.85),
                    Color.white.opacity(0.7),
                    UniFindStyle.paleTeal.opacity(0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(UniFindStyle.indigo.opacity(0.09))
                .frame(width: 260, height: 260)
                .blur(radius: 65)
                .offset(x: 150, y: -300)

            Circle()
                .fill(UniFindStyle.teal.opacity(0.10))
                .frame(width: 240, height: 240)
                .blur(radius: 65)
                .offset(x: -150, y: 250)
        }
        .ignoresSafeArea()
    }
}
