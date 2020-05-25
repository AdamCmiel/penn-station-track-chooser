import Foundation

enum Secret {
    static var API: String! {
        return infoForKey("MTA secret")
    }

    private static func infoForKey(_ key: String) -> String? {
       return (Bundle.main.infoDictionary?[key] as? String)?
           .replacingOccurrences(of: "\\", with: "")
    }
}
