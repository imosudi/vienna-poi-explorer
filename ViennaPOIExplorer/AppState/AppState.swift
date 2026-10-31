import Foundation
import CoreLocation

@MainActor
public final class AppState: ObservableObject {
    @Published public var pois: [POI] = []
    @Published public var isLoading = false
    @Published public var isNetworkAvailable = true
    @Published public var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var statusMessage = "Initial project scaffold ready."

    private let service = POIService.shared
    private let locationManager = CLLocationManager()

    public init() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        checkLocationPermission()
        loadInitialData()
    }

    public func refreshPOIs() async {
        isLoading = true
        statusMessage = "Loading points of interest..."

        do {
            if let url = URL(string: "https://data.wien.gv.at") {
                let items = try await service.fetchPOIs(from: url)
                pois = items.isEmpty ? service.fallbackPOIs() : items
                statusMessage = items.isEmpty ? "Using local fallback data." : "Live data loaded."
            } else {
                pois = service.fallbackPOIs()
                statusMessage = "Using local fallback data."
            }
        } catch {
            pois = service.fallbackPOIs()
            isNetworkAvailable = false
            statusMessage = "Network unavailable. Showing fallback data."
        }

        isLoading = false
    }

    private func loadInitialData() {
        pois = service.fallbackPOIs()
        statusMessage = "No live dataset is connected in this initial milestone."
    }

    private func checkLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        locationStatus = status
    }
}

extension AppState: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
    }
}
