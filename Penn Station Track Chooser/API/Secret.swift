import Foundation

enum Secret {
    static var API: String {
        return Secret["MTA secret"]!
    }
    
    private static subscript(key: String) -> String? {
       return (Bundle.main.infoDictionary?[key] as? String)?
           .replacingOccurrences(of: "\\", with: "")
    }
}
