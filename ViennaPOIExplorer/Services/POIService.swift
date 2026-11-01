import Foundation

public final class POIService {
    public static let shared = POIService()

    private init() {}

    public func fetchPOIs(from url: URL) async throws -> [POI] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let genericJSON = try JSONSerialization.jsonObject(with: data)
        return extractPOIs(from: genericJSON)
    }

    public func fallbackPOIs() -> [POI] {
        [
            POI(
                id: "fallback-1",
                name: "Vienna City Hall",
                category: "Landmark",
                latitude: 48.2082,
                longitude: 16.3738,
                address: "Rathausplatz 1",
                description: "Placeholder point of interest used while the live dataset is unavailable.",
                sourceURL: nil,
                isFavourite: false
            )
        ]
    }

    private func extractPOIs(from json: Any) -> [POI] {
        guard let root = json as? [String: Any] else {
            return []
        }

        let candidateKeys = ["results", "items", "features", "data", "records"]

        for key in candidateKeys {
            if let value = root[key] as? [[String: Any]] {
                return value.compactMap { POI(from: $0) }
            }

            if let nested = root[key] as? [Any] {
                let parsed = nested.compactMap { element -> POI? in
                    guard let dictionary = element as? [String: Any] else {
                        return nil
                    }
                    return POI(from: dictionary)
                }
                if parsed.isEmpty == false {
                    return parsed
                }
            }
        }

        if let properties = root["properties"] as? [String: Any], let poi = POI(from: properties) {
            return [poi]
        }

        if let feature = root["feature"] as? [String: Any], let poi = POI(from: feature) {
            return [poi]
        }

        return []
    }
}

private extension POI {
    init?(from dictionary: [String: Any]) {
        let baseDictionary: [String: Any]
        if let properties = dictionary["properties"] as? [String: Any] {
            baseDictionary = properties
        } else {
            baseDictionary = dictionary
        }

        let geometry = dictionary["geometry"] as? [String: Any]
        let coordinates = geometry?["coordinates"] as? [Any]

        let idValue = POI.stringValue(from: baseDictionary, keys: ["id", "uuid", "poi_id", "place_id"])
            ?? POI.stringValue(from: dictionary, keys: ["id", "uuid", "poi_id", "place_id"])
            ?? UUID().uuidString

        let nameValue = POI.stringValue(from: baseDictionary, keys: ["name", "title", "label", "display_name"]) ??
            POI.stringValue(from: dictionary, keys: ["name", "title", "label", "display_name"]) ??
            "Unnamed place"

        let categoryValue = POI.stringValue(from: baseDictionary, keys: ["category", "type", "kind", "class"])
            ?? POI.stringValue(from: dictionary, keys: ["category", "type", "kind", "class"])

        let latitudeValue = POI.doubleValue(from: baseDictionary, keys: ["latitude", "lat", "y"]) ??
            POI.doubleValue(from: dictionary, keys: ["latitude", "lat", "y"]) ??
            coordinateValue(from: coordinates, index: 1)

        let longitudeValue = POI.doubleValue(from: baseDictionary, keys: ["longitude", "lon", "lng", "x"]) ??
            POI.doubleValue(from: dictionary, keys: ["longitude", "lon", "lng", "x"]) ??
            coordinateValue(from: coordinates, index: 0)

        let addressValue = POI.stringValue(from: baseDictionary, keys: ["address", "street", "street_name", "location", "full_address"]) ??
            POI.stringValue(from: dictionary, keys: ["address", "street", "street_name", "location", "full_address"])

        let descriptionValue = POI.stringValue(from: baseDictionary, keys: ["description", "summary", "details", "descriptionText"]) ??
            POI.stringValue(from: dictionary, keys: ["description", "summary", "details", "descriptionText"])

        let sourceURLValue = POI.stringValue(from: baseDictionary, keys: ["source_url", "sourceUrl", "sourceURL"]) ??
            POI.stringValue(from: dictionary, keys: ["source_url", "sourceUrl", "sourceURL"])

        let isFavouriteValue = POI.boolValue(from: baseDictionary, keys: ["favourite", "favorite", "isFavourite"]) ||
            POI.boolValue(from: dictionary, keys: ["favourite", "favorite", "isFavourite"])

        self.id = idValue
        self.name = nameValue
        self.category = categoryValue
        self.latitude = latitudeValue
        self.longitude = longitudeValue
        self.address = addressValue
        self.description = descriptionValue
        self.sourceURL = sourceURLValue
        self.isFavourite = isFavouriteValue
    }

    static func coordinateValue(from coordinates: [Any]?, index: Int) -> Double? {
        guard let coordinates, coordinates.indices.contains(index) else {
            return nil
        }

        let value = coordinates[index]
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let string = value as? String, let parsed = Double(string) {
            return parsed
        }
        return nil
    }
}
