//
//  DTCCodeFixInfo.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 29.07.2026.
//

struct DTCCodeFixInfo {
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
    
    // TODO: удалить после реализации запроса
    init() {
        self.urgency = .high
        self.typicalFix = TypicalFix(from: 40, to: 650)
        self.drivable = Bool.random()
        self.means = "Your catalytic converter isn't cleaning exhaust gases as well as it should. The engine's downstream oxygen sensor sees readings too similar to the upstream sensor, so the car flags reduced converter efficiency. The car still drives, but emissions rise and it will fail an inspection."
        self.steps = [
            FixStep(title: "Check for exhaust leaks near the sensors", subTitle: "On the 2AR-FE, a leaking gasket at the front exhaust pipe throws false P0420. Inspect the flange between the manifold and the front pipe."),
            FixStep(title: "Replace the downstream O₂ sensor (Bank 1, Sensor 2)", subTitle: "A lazy rear oxygen sensor mimics a bad converter. Toyota part 89465-06280 fits the 2019 Camry. Clear the code and drive a full cycle to confirm."),
            FixStep(title: "Inspect the catalytic converter", subTitle: "If steps 1–2 don't clear it, the converter itself is likely worn. On the 2019 Camry it's covered by the 8-year / 80,000-mi federal emissions warranty — check before paying out of pocket.")
        ]
    }
    
    init?(response: Any) {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return nil }
        
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
