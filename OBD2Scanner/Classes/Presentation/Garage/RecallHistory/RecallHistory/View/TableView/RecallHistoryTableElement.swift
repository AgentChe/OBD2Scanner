//
//  RecallHistoryTableElement.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.08.2026.
//

import Foundation

struct RecallHistoryTableSection {
    let marked: Bool
    let lastChecked: Date?
}

enum RecallHistoryTableElement {
    case section(RecallHistoryTableSection)
    case recall(RecallHistory)
}
