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

extension POI {
    static func stringValue(from dictionary: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = dictionary[key] as? String {
                return value
            }
            if let value = dictionary[key] as? NSString {
                return value as String
            }
            if let value = dictionary[key] as? NSNumber {
                return value.stringValue
            }
        }
        return nil
    }

    static func boolValue(from dictionary: [String: Any], keys: [String]) -> Bool {
        for key in keys {
            if let value = dictionary[key] as? Bool {
                return value
            }
            if let value = dictionary[key] as? NSNumber {
                return value.boolValue
            }
            if let value = dictionary[key] as? NSString {
                let normalized = value.lowercased
                if normalized == "true" || normalized == "1" {
                    return true
                }
                if normalized == "false" || normalized == "0" {
                    return false
                }
            }
        }
        return false
    }

    static func doubleValue(from dictionary: [String: Any], keys: [String]) -> Double? {
        for key in keys {
            if let value = dictionary[key] as? Double {
                return value
            }
            if let value = dictionary[key] as? Int {
                return Double(value)
            }
            if let value = dictionary[key] as? NSNumber {
                return value.doubleValue
            }
            if let value = dictionary[key] as? String,
               let parsed = Double(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return parsed
            }
        }
        return nil
    }
}
