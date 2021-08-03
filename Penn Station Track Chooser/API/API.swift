import Combine
import Foundation

/// Subway line
enum Line: String {
    case _123 = "123"
    case ace
    case bdfm
}

private enum Endpoints {
    private static let REALTIME_FEED_URI = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-"
    
    private static func endpoint(apiKey key: String, line: Line) -> URL! {
        URL(string: "\(REALTIME_FEED_URI)\(line.rawValue)")
    }
    
    /// Request URL for a subway line
    /// - Parameter line: Subway line
    /// - Returns: RT Data feed URL
    fileprivate static func line(_ line: Line) -> URL {
        endpoint(apiKey: Secret.API, line: line)
    }
}

private extension String {
    var url: URL! { URL(string: self) }
}

enum API {
    enum APIError: Error {
        case protocolError
        case statusError
        case decodingError
    }

    static func requestFeed(forThe line: Line) async throws -> TransitRealtime_FeedMessage {
        let (data, response) = try await request(endpoint: Endpoints.line(line))
        guard let response = response as? HTTPURLResponse else {
            throw APIError.protocolError
        }
        
        guard response.statusCode == 200 /* OK */ else {
            throw APIError.statusError
        }
        
        return try TransitRealtime_FeedMessage(serializedData: data)
    }

    private static func request(endpoint: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: endpoint)
        request.setValue(Secret.API, forHTTPHeaderField: "X-API-KEY")
        return try await URLSession.shared.data(for: request)
    }
}
