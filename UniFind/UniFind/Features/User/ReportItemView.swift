
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

    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var submissionError = ""

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
            Form {

                // MARK: - Report Type

                Section("Report Type") {
                    Picker("Item Status", selection: $reportType) {
                        Text("Lost").tag("Lost")
                        Text("Found").tag("Found")
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Item Details

                Section("Item Details") {
                    TextField("Item name", text: $itemName)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }

                    TextField(
                        "Description",
                        text: $itemDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                // MARK: - Map Location

                Section("Pin the Item Location") {
                    MapLocationPickerView(
                        latitude: $latitude,
                        longitude: $longitude,
                        locationText: $location
                    )

                    TextField(
                        "Place name or additional details",
                        text: $location,
                        axis: .vertical
                    )
                    .textInputAutocapitalization(.words)

                    if latitude != nil && longitude != nil {
                        Label(
                            "Map pin selected",
                            systemImage: "checkmark.circle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.green)
                    } else {
                        Text(
                            "Tap the map to drop a pin. A pin is required to submit this report."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Item Photo and Computer Vision

                Section("Item Photo & Text Recognition") {

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            selectedImage == nil
                                ? "Choose Photo"
                                : "Change Photo",
                            systemImage: "photo"
                        )
                    }

                    if let image = selectedImage {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )

                        Button {
                            showTextScanner = true
                        } label: {
                            Label(
                                "Identify Text in Photo",
                                systemImage: "text.viewfinder"
                            )
                        }

                        Text(
                            "Scan the photo to detect visible text, such as ID numbers, names, and document details."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Button("Remove Photo", role: .destructive) {
                            selectedPhoto = nil
                            selectedImage = nil
                        }
                    }
                }

                // MARK: - Submit Report

                Section {
                    Button {
                        submitReport()
                    } label: {
                        HStack {
                            Spacer()

                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Submit \(reportType) Report")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        isSubmitting ||
                        itemName.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        location.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        latitude == nil ||
                        longitude == nil
                    )
                }
            }
            .navigationTitle("Report an Item")

            // MARK: - Load Selected Photo

            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadPhoto(from: newPhoto)
                }
            }

            // MARK: - Text Recognition Sheet

            .sheet(isPresented: $showTextScanner) {
                if let image = selectedImage {
                    ImageTextScannerView(image: image) { recognizedText in

                        let cleanedText = recognizedText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        guard !cleanedText.isEmpty else {
                            return
                        }

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

            // MARK: - Success Alert

            .alert(
                "Report Submitted",
                isPresented: $showingSuccess
            ) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Your report was saved successfully.")
            }

            // MARK: - Error Alert

            .alert(
                "Unable to Submit",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(submissionError)
            }
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
            submissionError = "Unable to load the selected photo."
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
            description: itemDescription.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            location: trimmedLocation,
            reportType: reportType,
            image: selectedImage,
            latitude: latitude,
            longitude: longitude
        )

        reportStore.addReport(report) { result in
            isSubmitting = false

            switch result {
            case .success:
                showingSuccess = true

            case .failure(let error):
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

        reportStore.clearError()
    }
}

#Preview {
    ReportItemView()
}
