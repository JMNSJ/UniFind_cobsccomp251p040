
import WidgetKit
import SwiftUI

@main
struct UniFindWidgetExtensionBundle: WidgetBundle {

    var body: some Widget {
        AdminPriorityRequestsWidget()
        HighPriorityAlertWidget()
    }
}
