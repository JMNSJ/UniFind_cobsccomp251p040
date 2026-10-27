
import SwiftUI
import WidgetKit

@main
struct UniFindWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        AdminPriorityRequestsWidget()
        HighPriorityAlertWidget()
    }
}
