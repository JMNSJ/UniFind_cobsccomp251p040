
import SwiftUI
import PhotosUI
import UIKit

struct ReportItemView: View {

    @ObservedObject private var reportStore = ReportStore.shared

    @State private var itemName = ""
    @State private var category = "Electronics"
    @State private var itemDescription = ""
    @State private var location = ""
    @State private var reportType = "Lost"

    @State private var latitude: Double?
    @State private var longitude: Double?

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @State private var showTextScanner = false
    @State private var requestHighPriority = false

    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var submissionError = ""
    @State private var successMessage = ""

    private let categories = [
        "Electronics",
        "Bags",
        "Books & Stationery",
        "Clothing",
        "ID Cards",
        "Keys",
        "Accessories",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    headerSection

                    reportTypeSection

                    itemDetailsSection

                    locationSection

                    photoSection

                    // High-priority requests are available only
                    // when reporting a lost item.
                    if reportType == "Lost" {
                        prioritySection
                    }

                    submitButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Report an Item")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadPhoto(from: newPhoto)
                }
            }
            .sheet(isPresented: $showTextScanner) {
                if let image = selectedImage {
                    ImageTextScannerView(image: image) { recognizedText in
                        let cleanedText = recognizedText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        guard !cleanedText.isEmpty else { return }

                        if itemDescription.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty {
                            itemDescription = cleanedText
                        } else {
                            itemDescription += "\n" + cleanedText
                        }
                    }
                }
            }
            .alert("Report Submitted", isPresented: $showingSuccess) {
                Button("Done", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text(successMessage)
            }
            .alert("Unable to Complete", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(submissionError)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(
                        LinearGradient(
                            colors: [.blue, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Help reunite items")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    Text("Share the details so your campus community can help.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 7) {
                Image(systemName: "info.circle.fill")
                Text("Please provide accurate report details.")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - Report Type

    private var reportTypeSection: some View {
        sectionCard(
            title: "What are you reporting?",
            subtitle: "Choose the option that matches your situation.",
            icon: "arrow.left.arrow.right"
        ) {
            HStack(spacing: 12) {
                reportTypeButton(
                    title: "I Lost It",
                    subtitle: "Find my item",
                    icon: "magnifyingglass",
                    type: "Lost"
                )

                reportTypeButton(
                    title: "I Found It",
                    subtitle: "Return an item",
                    icon: "hand.raised.fill",
                    type: "Found"
                )
            }
        }
    }

    private func reportTypeButton(
        title: String,
        subtitle: String,
        icon: String,
        type: String
    ) -> some View {
        let isSelected = reportType == type

        return Button {
            reportType = type

            // Clear the request when switching to Found.
            if type == "Found" {
                requestHighPriority = false
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .blue)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(
                        isSelected ? .white.opacity(0.85) : .secondary
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected
                        ? Color.blue
                        : Color(.tertiarySystemGroupedBackground)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Item Details

    private var itemDetailsSection: some View {
        sectionCard(
            title: "Item details",
            subtitle: "Add enough information to identify the item.",
            icon: "tag"
        ) {
            VStack(alignment: .leading, spacing: 16) {
                labeledField("Item name") {
                    TextField("e.g. Black leather wallet", text: $itemName)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                }

                labeledField("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                labeledField("Description") {
                    TextField(
                        "Colour, brand, distinguishing marks...",
                        text: $itemDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .textInputAutocapitalization(.sentences)
                }
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        sectionCard(
            title: "Where was it?",
            subtitle: "Select a map pin and add a place description.",
            icon: "mappin.and.ellipse"
        ) {
            VStack(alignment: .leading, spacing: 13) {
                MapLocationPickerView(
                    latitude: $latitude,
                    longitude: $longitude,
                    locationText: $location
                )

                labeledField("Location details") {
                    TextField(
                        "e.g. Library, second floor",
                        text: $location,
                        axis: .vertical
                    )
                    .lineLimit(2...4)
                    .textInputAutocapitalization(.words)
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(
                        systemName:
                            latitude != nil && longitude != nil
                            ? "checkmark.circle.fill"
                            : "info.circle.fill"
                    )
                    .foregroundStyle(
                        latitude != nil && longitude != nil
                        ? .green
                        : .secondary
                    )

                    Text(
                        latitude != nil && longitude != nil
                        ? "Map pin selected."
                        : "Tap the map to select a pin. A pin is required."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Photo

    private var photoSection: some View {
        sectionCard(
            title: "Add a photo",
            subtitle: "A clear photo can help identify the item.",
            icon: "camera"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                selectedPhoto = nil
                                selectedImage = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(9)
                                    .background(.black.opacity(0.65))
                                    .clipShape(Circle())
                            }
                            .padding(10)
                            .accessibilityLabel("Remove photo")
                        }

                    Button {
                        showTextScanner = true
                    } label: {
                        Label(
                            "Recognise text in photo",
                            systemImage: "text.viewfinder"
                        )
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Text("Text recognition can help copy visible text into the description.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 30))
                                .foregroundStyle(.blue)

                            Text("Choose an image")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("Select a photo from your photo library")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(Color.blue.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    Color.blue.opacity(0.25),
                                    style: StrokeStyle(
                                        lineWidth: 1,
                                        dash: [6]
                                    )
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }

                if selectedImage != nil {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Change photo",
                            systemImage: "arrow.triangle.2.circlepath"
                        )
                        .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    // MARK: - Priority Request
    // Displayed only when reportType == "Lost".

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 3) {
                    Text("High-priority alert")
                        .font(.headline)

                    Text("Request admin review")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle(
                    "Request high-priority alert",
                    isOn: $requestHighPriority
                )
                .labelsHidden()
                .tint(.orange)
                .accessibilityLabel("Request high-priority alert")
            }

            Text(
                "Use this for urgent lost items such as student ID cards, " +
                "keys, or important documents. An administrator must " +
                "approve the request before an alert is broadcast."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if requestHighPriority {
                Label(
                    "Your request will be submitted as pending approval.",
                    systemImage: "clock.badge.checkmark"
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(.orange)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(17)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    requestHighPriority
                    ? Color.orange.opacity(0.55)
                    : Color.clear,
                    lineWidth: 1.5
                )
        }
        .animation(.easeInOut(duration: 0.2), value: requestHighPriority)
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            submitReport()
        } label: {
            HStack(spacing: 10) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)

                    Text("Submitting...")
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "paperplane.fill")

                    Text("Submit \(reportType) Report")
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [.blue, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
        .opacity(canSubmit ? 1 : 0.55)
    }

    private var canSubmit: Bool {
        !isSubmitting &&
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        latitude != nil &&
        longitude != nil
    }

    // MARK: - Reusable UI

    private func sectionCard<Content: View>(
        title: String,
        subtitle: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(alignment: .top, spacing: 11) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(width: 38, height: 38)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func labeledField<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .padding(.horizontal, 13)
                .padding(.vertical, 12)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Load Photo

    private func loadPhoto(from photo: PhotosPickerItem?) async {
        guard let photo else {
            selectedImage = nil
            return
        }

        do {
            if let data = try await photo.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            } else {
                submissionError = "Unable to load the selected photo."
                showingError = true
            }
        } catch {
            submissionError =
                "Unable to load the selected photo: \(error.localizedDescription)"
            showingError = true
        }
    }

    // MARK: - Submit Report

    private func submitReport() {
        let trimmedName = itemName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedLocation = location.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedDescription = itemDescription.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty,
              !trimmedLocation.isEmpty,
              let latitude,
              let longitude else {
            submissionError =
                "Enter an item name, select a map pin, and provide a location description."
            showingError = true
            return
        }

        isSubmitting = true

        let report = LostFoundItem(
            itemName: trimmedName,
            category: category,
            description: trimmedDescription,
            location: trimmedLocation,
            reportType: reportType,
            image: selectedImage,
            latitude: latitude,
            longitude: longitude
        )

        reportStore.addReport(report) { result in
            switch result {
            case .success:
                // Extra safeguard: only Lost reports can create
                // high-priority requests.
                if reportType == "Lost" && requestHighPriority {
                    PriorityAlertRequestStore.shared.createRequest(
                        itemName: trimmedName,
                        description: trimmedDescription,
                        location: trimmedLocation
                    ) { requestResult in
                        isSubmitting = false

                        switch requestResult {
                        case .success:
                            successMessage =
                                "Your report was saved, and your high-priority request was sent to the administrators for review."

                            showingSuccess = true

                        case .failure(let error):
                            submissionError =
                                "Your report was saved, but the priority request could not be submitted. \(error.localizedDescription)"

                            showingError = true
                        }
                    }
                } else {
                    isSubmitting = false
                    successMessage = "Your report was submitted successfully."
                    showingSuccess = true
                }

            case .failure(let error):
                isSubmitting = false
                submissionError = error.localizedDescription
                showingError = true
            }
        }
    }

    // MARK: - Reset Form

    private func resetForm() {
        itemName = ""
        category = "Electronics"
        itemDescription = ""
        location = ""
        reportType = "Lost"

        latitude = nil
        longitude = nil

        selectedPhoto = nil
        selectedImage = nil

        showTextScanner = false
        requestHighPriority = false

        reportStore.clearError()
    }
}

#Preview {
    ReportItemView()
}
