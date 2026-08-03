//
//  RecallHistory.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import Foundation

struct RecallHistory {
    enum Level: String {
        case critical, moderate, low
    }
    
    let id: String
    let date: String
    let marked: Bool
    let level: Level
    let link: URL
    let notes: String?
    let reason: String?
    let reasonContent: String?
    let remedy: String?
    
    init?(json: [String: Any]) {
        guard
            let id = json["recall_id"] as? String,
            let date = json["date"] as? String,
            let marked = json["is_marked"] as? Bool,
            let level: Level = {
                guard let rawValue = json["level"] as? String else { return nil }
                return Level(rawValue: rawValue)
            }(),
            let link: URL = {
                guard let string = json["link"] as? String else { return nil }
                return URL(string: string)
            }()
        else { return nil }
        
        self.id = id
        self.date = date
        self.marked = marked
        self.level = level
        self.link = link
        self.notes = json["notes"] as? String
        self.reason = json["reason"] as? String
        self.reasonContent = json["reason_content"] as? String
        self.remedy = json["remedy"] as? String
    }
}

// MARK: Public
extension RecallHistory {
    static func make(response: Any) -> Page<[RecallHistory]>? {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let items = body["items"] as? [[String: Any]],
            let pageInfoJSON = body["pagination"] as? [String: Any],
            let pageInfo = PageInfo(json: pageInfoJSON)
        else { return nil }
        
        let recallHistory = items.compactMap { RecallHistory(json: $0) }
        
        return Page(info: pageInfo, elements: recallHistory)
    }
}
