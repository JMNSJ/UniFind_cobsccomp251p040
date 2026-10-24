
import SwiftUI
import UIKit

struct ImageTextScannerView: View {

    let image: UIImage
    let onUseText: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var extractedText = ""
    @State private var isScanning = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    Text("Scan Text from Photo")
                        .font(.title2.bold())

                    Text(
                        "UniFind will look for readable text, " +
                        "such as ID numbers, names and document details."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Button {
                        scanImage()
                    } label: {
                        HStack {
                            if isScanning {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "text.viewfinder")
                            }

                            Text(
                                isScanning
                                ? "Scanning Image..."
                                : "Recognize Text"
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isScanning)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    if !extractedText.isEmpty {
                        Text("Recognized Text")
                            .font(.headline)

                        TextEditor(text: $extractedText)
                            .frame(minHeight: 150)
                            .padding(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.4))
                            }

                        Text(
                            "Check the result carefully. " +
                            "Incorrect characters or numbers may be detected."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Button {
                            onUseText(extractedText)
                            dismiss()
                        } label: {
                            Label(
                                "Use Text in Report",
                                systemImage: "checkmark.circle.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else if !isScanning && errorMessage == nil {
                        Text(
                            "The extracted text will appear here. " +
                            "Make sure the photo is clear and well lit."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Text Recognition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func scanImage() {
        isScanning = true
        errorMessage = nil
        extractedText = ""

        TextRecognitionService.shared.recognizeText(in: image) { result in
            isScanning = false

            switch result {
            case .success(let text):
                if text.isEmpty {
                    errorMessage =
                        "No readable text found. Try a clearer photo."
                } else {
                    extractedText = text
                }

            case .failure(let error):
                errorMessage =
                    "Could not scan this image: \(error.localizedDescription)"
            }
        }
    }
}
