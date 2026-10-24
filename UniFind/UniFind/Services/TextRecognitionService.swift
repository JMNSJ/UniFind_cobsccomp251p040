
import Foundation
import UIKit
import Vision

final class TextRecognitionService {

    static let shared = TextRecognitionService()

    private init() {}

    func recognizeText(
        in image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(
                .failure(
                    NSError(
                        domain: "UniFind.TextRecognition",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Unable to read this image. Please select another photo."
                        ]
                    )
                )
            )
            return
        }

        let request = VNRecognizeTextRequest { request, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let observations =
                request.results as? [VNRecognizedTextObservation] ?? []

            let recognizedLines = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let extractedText = recognizedLines.joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            DispatchQueue.main.async {
                completion(.success(extractedText))
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en"]

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(
                    cgImage: cgImage,
                    options: [:]
                )

                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
