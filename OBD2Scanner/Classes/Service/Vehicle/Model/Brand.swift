//
//  Brand.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import Foundation

struct Brand {
    let name: String
    let logo: URL?
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String else { return nil }
        
        self.name = name
        self.logo = {
            guard let string = json["logo"] as? String else { return nil }
            return URL(string: string)
        }()
    }
}

// MARK: Public
extension Brand {
    static func map(from response: Any) -> [Brand] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let brands = body["brands"] as? [[String: Any]]
        else { return [] }
        
        return brands.compactMap { Brand(json: $0) }
    }
}
