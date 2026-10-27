
import Testing
@testable import UniFind

struct PriorityAlertPolicyTests {

    @Test
    func validPriorityRequestIsAccepted() {
        #expect(
            PriorityAlertPolicy.canCreateRequest(
                isSignedIn: true,
                itemName: "Student ID Card",
                description: "Needed for an examination",
                location: "University Library"
            )
        )
    }

    @Test
    func signedOutUserCannotCreateRequest() {
        #expect(
            !PriorityAlertPolicy.canCreateRequest(
                isSignedIn: false,
                itemName: "Student ID Card",
                description: "Needed for an examination",
                location: "University Library"
            )
        )
    }

    @Test
    func emptyItemNameIsRejected() {
        #expect(
            !PriorityAlertPolicy.isValidRequest(
                itemName: " ",
                description: "Urgent item",
                location: "Library"
            )
        )
    }

    @Test
    func emptyDescriptionIsRejected() {
        #expect(
            !PriorityAlertPolicy.isValidRequest(
                itemName: "Student ID Card",
                description: "",
                location: "Library"
            )
        )
    }

    @Test
    func emptyLocationIsRejected() {
        #expect(
            !PriorityAlertPolicy.isValidRequest(
                itemName: "Student ID Card",
                description: "Urgent item",
                location: " "
            )
        )
    }

    @Test
    func adminCanReviewPendingRequest() {
        #expect(
            PriorityAlertPolicy.canReviewRequest(
                isAdmin: true,
                status: "pending"
            )
        )
    }

    @Test
    func ordinaryUserCannotReviewPendingRequest() {
        #expect(
            !PriorityAlertPolicy.canReviewRequest(
                isAdmin: false,
                status: "pending"
            )
        )
    }

    @Test
    func approvedRequestCannotBeReviewedAgain() {
        #expect(
            !PriorityAlertPolicy.canReviewRequest(
                isAdmin: true,
                status: "approved"
            )
        )
    }

    @Test
    func rejectedRequestCannotBeReviewedAgain() {
        #expect(
            !PriorityAlertPolicy.canReviewRequest(
                isAdmin: true,
                status: "rejected"
            )
        )
    }

    @Test
    func approvedAlertCanBeBroadcast() {
        #expect(
            PriorityAlertPolicy.canBroadcastAlert(
                status: "approved"
            )
        )
    }

    @Test
    func pendingAlertCannotBeBroadcast() {
        #expect(
            !PriorityAlertPolicy.canBroadcastAlert(
                status: "pending"
            )
        )
    }

    @Test
    func rejectedAlertCannotBeBroadcast() {
        #expect(
            !PriorityAlertPolicy.canBroadcastAlert(
                status: "rejected"
            )
        )
    }
}
