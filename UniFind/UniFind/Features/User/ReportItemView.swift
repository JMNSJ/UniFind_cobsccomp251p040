
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
                Section("Report Type") {
                    Picker("Item Status", selection: $reportType) {
                        Text("Lost").tag("Lost")
                        Text("Found").tag("Found")
                    }
                    .pickerStyle(.segmented)
                }

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

                Section("Item Photo") {
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
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )

                        Button("Remove Photo", role: .destructive) {
                            selectedPhoto = nil
                            selectedImage = nil
                        }
                    }
                }

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
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadPhoto(from: newPhoto)
                }
            }
            .alert("Report Submitted", isPresented: $showingSuccess) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Your report was saved successfully.")
            }
            .alert("Unable to Submit", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(submissionError)
            }
        }
    }

    private func loadPhoto(from photo: PhotosPickerItem?) async {
        guard let photo else {
            selectedImage = nil
            return
        }

        do {
            if let data = try await photo.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            submissionError = "Unable to load the selected photo."
            showingError = true
        }
    }

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
        reportStore.clearError()
    }
}

#Preview {
    ReportItemView()
}
