//
//  Brand.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import Foundation

struct Brand: Codable, Hashable {
    let name: String
    
    var logo: URL? {
        var components = URLComponents()
        components.scheme = GlobalDefinitions.cdnScheme
        components.host = GlobalDefinitions.cdnHost
        components.path = "/car_connect/logo/\(name).png"
        return components.url
    }
}

// MARK: Public
extension Brand {
    static func map(from response: Any) -> [Brand] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return [] }
        
        let names = (body["brands"] as? [String]) ?? []
        return names.map { Brand(name: $0) }
    }
}
