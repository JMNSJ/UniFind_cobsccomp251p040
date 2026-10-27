
import Foundation

enum AppDestination: Hashable {
    case adminDashboard
    case priorityRequests
    case priorityRequestDetail(String)
    case adminAlerts
    case priorityAlertRequest
    case priorityAlerts
}
