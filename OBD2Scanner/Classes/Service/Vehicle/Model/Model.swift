//
//  Model.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import Foundation

struct Model {
    let name: String
    let preview: URL?
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String else { return nil }
        
        self.name = name
        self.preview = {
            guard let string = json["preview"] as? String else { return nil }
            return URL(string: string)
        }()
    }
}

// MARK: Public
extension Model {
    static func makeModels(from response: Any) -> [Model] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let models = body["models"] as? [[String: Any]]
        else { return [] }
        
        return models.compactMap { Model(json: $0) }
    }
}
