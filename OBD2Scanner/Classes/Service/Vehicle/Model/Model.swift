//
//  Model.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 30.06.2026.
//

import Foundation

typealias Model = String

// MARK: Public
extension Model {
    static func makeModels(from response: Any) -> [Model] {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return [] }
        
        let models = (body["models"] as? [String]) ?? []
        return models.map { Model($0) }
    }
}
