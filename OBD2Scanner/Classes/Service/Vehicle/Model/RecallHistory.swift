//
//  RecallHistory.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 05.07.2026.
//

import Foundation

struct RecallHistoryList {
    let items: [RecallHistory]
    let lastChecked: Date?
    
    init?(response: Any) {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let items = body["items"] as? [[String: Any]]
        else { return nil }

        let lastChecked: Date? = {
            guard let timestamp = body["last_checked_at"] as? TimeInterval, timestamp > 0 else { return nil }
            return Date(timeIntervalSince1970: timestamp)
        }()
        
        self.items = items.compactMap { RecallHistory(json: $0) }
        self.lastChecked = lastChecked
    }
}

struct RecallHistory {
    enum Level: String {
        case critical, moderate, low
    }

    let id: String
    var marked: Bool
    let level: Level
    let date: Date?
    let link: URL?
    let notes: String?
    let reason: String?
    let reasonContent: String?
    let remedy: String?

    init?(json: [String: Any]) {
        guard
            let id = json["recall_id"] as? String,
            let marked = json["is_marked"] as? Bool,
            let level: Level = {
                guard let rawValue = json["level"] as? String else { return nil }
                return Level(rawValue: rawValue)
            }()
        else { return nil }

        self.id = id
        self.marked = marked
        self.level = level
        self.date = {
            guard let timestamp = json["date"] as? TimeInterval, timestamp > 0 else { return nil }
            return Date(timeIntervalSince1970: timestamp)
        }()
        self.link = {
            guard let string = json["link"] as? String else { return nil }
            return URL(string: string)
        }()
        self.notes = json["notes"] as? String
        self.reason = json["reason"] as? String
        self.reasonContent = json["reason_content"] as? String
        self.remedy = json["remedy"] as? String
    }
}
