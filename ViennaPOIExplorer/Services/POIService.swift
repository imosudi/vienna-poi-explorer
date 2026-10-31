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
                return value.compactMap(POI.init(from:))
            }
        }

        if let results = root["results"] as? [Any] {
            return results.compactMap { item in
                guard let dictionary = item as? [String: Any] else {
                    return nil
                }
                return POI(from: dictionary)
            }
        }

        return []
    }
}

private extension POI {
    init?(from dictionary: [String: Any]) {
        let idValue = dictionary["id"] as? String ?? dictionary["uuid"] as? String ?? UUID().uuidString
        let nameValue = dictionary["name"] as? String ?? dictionary["title"] as? String ?? "Unnamed place"
        let categoryValue = dictionary["category"] as? String ?? dictionary["type"] as? String
        let latitudeValue = dictionary["latitude"] as? Double ?? dictionary["lat"] as? Double
        let longitudeValue = dictionary["longitude"] as? Double ?? dictionary["lon"] as? Double ?? dictionary["lng"] as? Double
        let addressValue = dictionary["address"] as? String ?? dictionary["street"] as? String
        let descriptionValue = dictionary["description"] as? String ?? dictionary["summary"] as? String
        let sourceURLValue = dictionary["source_url"] as? String ?? dictionary["sourceUrl"] as? String
        let isFavouriteValue = dictionary["favourite"] as? Bool ?? false

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
}
