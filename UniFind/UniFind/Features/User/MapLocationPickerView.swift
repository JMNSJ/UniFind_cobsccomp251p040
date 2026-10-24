import Combine
import SwiftUI
import MapKit
import CoreLocation

struct MapLocationPickerView: View {
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var locationText: String

    @StateObject private var locationManager = MapLocationManager()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 6.9271,
                longitude: 79.8612
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.04,
                longitudeDelta: 0.04
            )
        )
    )

    private var selectedCoordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }

        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let coordinate = selectedCoordinate {
                        Marker(
                            "Selected Item Location",
                            coordinate: coordinate
                        )
                        .tint(.green)
                    }
                }
                .onTapGesture { point in
                    guard let coordinate = proxy.convert(
                        point,
                        from: .local
                    ) else {
                        return
                    }

                    selectLocation(coordinate)
                }
                .frame(height: 300)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }

            Button {
                locationManager.requestCurrentLocation()
            } label: {
                HStack {
                    if locationManager.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "location.fill")
                    }

                    Text(
                        locationManager.isLoading
                            ? "Finding Current Location..."
                            : "Use Current Location"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.78, green: 0.96, blue: 0.40))
            .foregroundStyle(.black)
            .disabled(locationManager.isLoading)

            if let coordinate = selectedCoordinate {
                Label(
                    String(
                        format: "%.5f, %.5f",
                        coordinate.latitude,
                        coordinate.longitude
                    ),
                    systemImage: "mappin.and.ellipse"
                )
                .font(.caption)
                .textSelection(.enabled)
            } else {
                Text("Tap the map to drop a pin at the item location.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = locationManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onReceive(locationManager.$coordinate) { coordinate in
            guard let coordinate else { return }
            selectLocation(coordinate)
        }
        .onReceive(locationManager.$address) { address in
            guard let address, !address.isEmpty else { return }
            locationText = address
        }
    }

    private func selectLocation(
        _ coordinate: CLLocationCoordinate2D
    ) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude

        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.008,
                    longitudeDelta: 0.008
                )
            )
        )

        locationManager.lookupAddress(for: coordinate)
    }
}

@MainActor
final class MapLocationManager: NSObject,
                               ObservableObject,
                               CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var address: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var waitingForPermission = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() {
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            waitingForPermission = true
            manager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            isLoading = true
            manager.requestLocation()

        case .denied, .restricted:
            errorMessage =
                "Location permission is unavailable. You can still tap the map to select a pin."

        @unknown default:
            errorMessage = "Unable to check location permission."
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        guard waitingForPermission else { return }
        waitingForPermission = false

        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            isLoading = true
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied ||
                  manager.authorizationStatus == .restricted {
            errorMessage =
                "Location access was denied. Tap the map to select a pin manually."
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latest = locations.last else {
            isLoading = false
            errorMessage = "No location was returned. Please try again."
            return
        }

        coordinate = latest.coordinate
        isLoading = false
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        isLoading = false
        errorMessage =
            "Unable to get your current location. You can select a pin manually."
    }

    func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        geocoder.cancelGeocode()

        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks, error in

            guard let self else { return }

            Task { @MainActor in
                guard error == nil,
                      let place = placemarks?.first else {
                    return
                }

                let parts = [
                    place.name,
                    place.subLocality,
                    place.locality,
                    place.administrativeArea
                ]

                let uniqueParts = parts
                    .compactMap { $0 }
                    .reduce(into: [String]()) { result, part in
                        if !result.contains(part) {
                            result.append(part)
                        }
                    }

                if !uniqueParts.isEmpty {
                    self.address = uniqueParts.joined(separator: ", ")
                }
            }
        }
    }
}
