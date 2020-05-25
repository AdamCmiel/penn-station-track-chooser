import Foundation

private enum Line: Int {
    case mta123 = 1
    case mtaABC = 26
    case mtaBDFM = 21
}

private enum Endpoints {
    private static let SERVICE_STATUS_URI = "http://web.mta.info/status/ServiceStatusSubway.xml"
    
    private static func endpoint(apiKey key: String, line: Line) -> URL! {
        URL(string: "https://datamine.mta.info/mta_esi.php?key=\(key)&feed_id=\(line.rawValue)")
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

    static func requestFeed(completion: @escaping (Result<TransitRealtime_FeedMessage, APIError>) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.line(.mtaABC)) { data, response, error in
            if let entities = try? TransitRealtime_FeedMessage(serializedData: data!) {
                completion(.success(entities))
            } else {
                completion(.failure(.decodingError))
            }
        }

        task.resume()
    }
}
