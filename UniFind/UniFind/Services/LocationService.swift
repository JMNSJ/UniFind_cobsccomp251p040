
import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject,
                             CLLocationManagerDelegate {

    @Published var locationText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() {
        errorMessage = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            isLoading = true
            locationManager.requestLocation()

        case .denied, .restricted:
            errorMessage =
                "Location permission is unavailable. Enable it in Settings, or enter the location manually."

        @unknown default:
            errorMessage = "Unable to check location permission."
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // The user has just granted permission.
            // Start getting the location when they requested it.
            break

        case .denied, .restricted:
            isLoading = false
            errorMessage =
                "Location access was denied. You can enter the location manually."

        default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            isLoading = false
            errorMessage = "Could not find your current location."
            return
        }

        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks, error in

            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                if error != nil {
                    self.errorMessage =
                        "Coordinates found, but the address could not be determined. Enter a location manually."
                    return
                }

                guard let place = placemarks?.first else {
                    self.errorMessage =
                        "No readable address was found. Enter a location manually."
                    return
                }

                let parts = [
                    place.name,
                    place.subLocality,
                    place.locality,
                    place.administrativeArea
                ]

                let readableLocation = parts
                    .compactMap { $0 }
                    .reduce(into: [String]()) { result, part in
                        if !result.contains(part) {
                            result.append(part)
                        }
                    }
                    .joined(separator: ", ")

                if !readableLocation.isEmpty {
                    self.locationText = readableLocation
                    self.errorMessage = nil
                } else {
                    self.errorMessage =
                        "No readable address was found. Enter a location manually."
                }
            }
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage =
                "Could not get your location. Check Location Services and try again."
        }
    }
}
