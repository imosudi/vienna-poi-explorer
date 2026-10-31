import Foundation
import CoreLocation
import MapKit

public struct POI: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let category: String?
    public let latitude: Double?
    public let longitude: Double?
    public let address: String?
    public let description: String?
    public let sourceURL: String?
    public let isFavourite: Bool

    public var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var mapAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.subtitle = category
        if let coordinate {
            annotation.coordinate = coordinate
        }
        return annotation
    }
}
