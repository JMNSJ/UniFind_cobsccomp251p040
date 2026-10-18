
import SwiftUI
import PhotosUI
import UIKit

struct ReportItemView: View {
    @State private var itemName = ""
    @State private var category = "Electronics"
    @State private var description = ""
    @State private var location = ""
    @State private var reportType = "Lost"

    // Photo selection states
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    @State private var showingConfirmation = false

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

    private let reportTypes = ["Lost", "Found"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Report Type") {
                    Picker("Type", selection: $reportType) {
                        ForEach(reportTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Item Details") {
                    TextField("Item Name", text: $itemName)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { itemCategory in
                            Text(itemCategory).tag(itemCategory)
                        }
                    }

                    TextField(
                        "Description",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("Item Photograph") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 220)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            Label(
                                "Change Photo",
                                systemImage: "photo"
                            )
                        }

                        Button(role: .destructive) {
                            selectedPhoto = nil
                            selectedImage = nil
                        } label: {
                            Label(
                                "Remove Photo",
                                systemImage: "trash"
                            )
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            Label(
                                "Choose a Photo",
                                systemImage: "photo.badge.plus"
                            )
                        }

                        Text(
                            "Add a clear photograph to help identify the item."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Section("Location") {
                    TextField(
                        "Where was it lost or found?",
                        text: $location
                    )
                }

                Section {
                    Button {
                        showingConfirmation = true
                    } label: {
                        Text("Submit Report")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(
                        itemName.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
            .navigationTitle("Report an Item")
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadPhoto(from: newPhoto)
                }
            }
            .alert(
                "Report Submitted",
                isPresented: $showingConfirmation
            ) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                Text(
                    "Your \(reportType.lowercased()) item report has been recorded for this demo."
                )
            }
        }
    }

    @MainActor
    private func loadPhoto(from photo: PhotosPickerItem?) async {
        guard let photo else {
            selectedImage = nil
            return
        }

        do {
            if let imageData = try await photo.loadTransferable(
                type: Data.self
            ),
            let image = UIImage(data: imageData) {
                selectedImage = image
            }
        } catch {
            print("Failed to load selected photo: \(error)")
        }
    }

    private func resetForm() {
        itemName = ""
        category = "Electronics"
        description = ""
        location = ""
        reportType = "Lost"
        selectedPhoto = nil
        selectedImage = nil
    }
}

#Preview {
    ReportItemView()
}
