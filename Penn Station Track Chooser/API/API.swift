import Combine
import Foundation

private enum Line: String {
    case _123 = "123"
    case ace
    case bdfm
}

private enum Endpoints {
    private static let REALTIME_FEED_URI = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-"
    
    private static func endpoint(apiKey key: String, line: Line) -> URL! {
        URL(string: "\(REALTIME_FEED_URI)\(line.rawValue)")
    }

    fileprivate static func line(_ line: Line) -> URL {
        endpoint(apiKey: Secret.API, line: line)
    }
}

private extension String {
    var url: URL! { URL(string: self) }
}

enum API {
    enum APIError: Error {
        case decodingError
    }

    static func requestFeed() -> AnyPublisher<TransitRealtime_FeedMessage, Error> {
        return request(endpoint: Endpoints.line(.ace)) { data in
            try TransitRealtime_FeedMessage(serializedData: data)
        }.eraseToAnyPublisher()
    }

    private static func request<T>(endpoint: URL, transform: @escaping (Data) throws -> T)
        -> AnyPublisher<T, Error>
    {
        var request = URLRequest(url: endpoint)
        request.setValue(Secret.API, forHTTPHeaderField: "X-API-KEY")
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            return try transform(data)
        }.eraseToAnyPublisher()
    }
}
