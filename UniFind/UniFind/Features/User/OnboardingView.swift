
import SwiftUI

struct OnboardingView: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 90))
                .foregroundStyle(.blue)

            Text("UniFind")
                .font(.largeTitle.bold())

            Text("Lost something on campus?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Report lost and found items, discover possible matches, and reconnect with your belongings.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
