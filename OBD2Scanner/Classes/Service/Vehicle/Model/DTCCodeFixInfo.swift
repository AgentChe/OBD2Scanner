//
//  DTCCodeFixInfo.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct DTCCodeFixInfo {
    enum Status {
        case inProcessing
        case completed(DTCCodeFixInfo)
    }

    enum Urgency {
        case low, medium, high
    }
    
    struct TypicalFix {
        let from: Int
        let to: Int
    }
    
    struct FixStep {
        let title: String
        let subTitle: String
    }
    
    let urgency: Urgency
    let typicalFix: TypicalFix
    let drivable: Bool
    let means: String
    let steps: [FixStep]
    
    init?(json body: [String: Any]) {
        let urgency: Urgency? = {
            guard let rawValue = body["urgency"] as? String else { return nil }
            
            switch rawValue.lowercased() {
            case "low":
                return .low
            case "medium":
                return .medium
            case "high":
                return .high
            default:
                return nil
            }
        }()
        guard let urgency else { return nil }
        self.urgency = urgency
        
        let typicalFix: TypicalFix? = {
            guard
                let json = body["typical_fix"] as? [String: Any],
                let from = json["from"] as? Int,
                let to = json["to"] as? Int
            else { return nil }
            
            return TypicalFix(from: from, to: to)
        }()
        guard let typicalFix else { return nil }
        self.typicalFix = typicalFix
        
        guard let drivable = body["drivable"] as? Bool else { return nil }
        self.drivable = drivable
        
        guard let means = body["means"] as? String else { return nil }
        self.means = means
        
        let steps: [FixStep]? = {
            guard let array = body["steps"] as? [[String: Any]] else { return nil }
            
            return array.compactMap { json -> FixStep? in
                guard
                    let title = json["title"] as? String,
                    let subTitle = json["subtitle"] as? String
                else { return nil }
                
                return FixStep(title: title, subTitle: subTitle)
            }
        }()
        guard let steps else { return nil }
        self.steps = steps
    }
}

// MARK: Public
extension DTCCodeFixInfo {
    static func status(response: Any) -> Status? {
        guard let json = response as? [String: Any] else { return nil }

        let errorCode: Int? = {
            guard let errorJSON = json["error"] as? [String: Any] else { return nil }

            return errorJSON["code"] as? Int
        }()
        if errorCode == 409 {
            return .inProcessing
        }

        guard let body = json["body"] as? [String: Any] else { return nil }

        switch body["status"] as? String {
        case "in_processing":
            return .inProcessing
        case "completed":
            guard
                let result = body["result"] as? [String: Any],
                let info = DTCCodeFixInfo(json: result)
            else { return nil }

            return .completed(info)
        default:
            return nil
        }
    }
}
