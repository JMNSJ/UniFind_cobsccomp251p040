import Testing
@testable import UniFind

struct ReportValidatorTests {

    @Test
    func acceptsValidReport() {
        #expect(
            ReportValidator.validate(
                itemName: "Black Wallet",
                description: "Black leather wallet",
                location: "University Library"
            ) == true
        )
    }

    @Test
    func rejectsEmptyItemName() {
        #expect(
            ReportValidator.validate(
                itemName: "",
                description: "Black leather wallet",
                location: "University Library"
            ) == false
        )
    }

    @Test
    func rejectsWhitespaceOnlyItemName() {
        #expect(
            ReportValidator.validate(
                itemName: "   \n ",
                description: "Black leather wallet",
                location: "University Library"
            ) == false
        )
    }

    @Test
    func rejectsEmptyDescription() {
        #expect(
            ReportValidator.validate(
                itemName: "Black Wallet",
                description: "",
                location: "University Library"
            ) == false
        )
    }

    @Test
    func rejectsWhitespaceOnlyDescription() {
        #expect(
            ReportValidator.validate(
                itemName: "Black Wallet",
                description: "   ",
                location: "University Library"
            ) == false
        )
    }

    @Test
    func rejectsEmptyLocation() {
        #expect(
            ReportValidator.validate(
                itemName: "Black Wallet",
                description: "Black leather wallet",
                location: ""
            ) == false
        )
    }

    @Test
    func rejectsWhitespaceOnlyLocation() {
        #expect(
            ReportValidator.validate(
                itemName: "Black Wallet",
                description: "Black leather wallet",
                location: "   "
            ) == false
        )
    }
}
