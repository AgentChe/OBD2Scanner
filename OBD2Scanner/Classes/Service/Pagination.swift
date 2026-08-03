//
//  Pagination.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 03.08.2026.
//

struct Page<T> {
    let info: PageInfo
    let elements: T
}

struct PageInfo {
    let current: Int
    let next: Int
    let total: Int
    
    init?(json: [String: Any]) {
        guard
            let current = json["current"] as? Int,
            let next = json["next"] as? Int,
            let total = json["total"] as? Int
        else { return nil }
        
        self.current = current
        self.next = next
        self.total = total
    }
}
