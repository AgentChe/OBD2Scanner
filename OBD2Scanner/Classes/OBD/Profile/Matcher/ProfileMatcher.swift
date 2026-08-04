//
//  ProfileMatcher.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Данные автомобиля, по которым подбирается профиль.
/// Берутся из гаража пользователя и/или из прочитанного VIN.
struct VehicleDescriptor: Equatable {
    let brand: String?
    let model: String?
    let vin: String?
    let year: Int?
    let fuelType: String?

    /// World Manufacturer Identifier — первые 3 символа VIN.
    var wmi: String? {
        guard let vin, vin.count >= 3 else { return nil }
        return String(vin.prefix(3)).uppercased()
    }
}

/// Подбор профилей под конкретный автомобиль.
enum ProfileMatcher {
    /// Результат подбора: стандартный профиль (всегда) + лучший производительский.
    struct Selection: Equatable {
        /// Базовый профиль SAE J1979 — работает на любой машине.
        let standard: OBDProfile?
        /// Наиболее специфичный подходящий производительский профиль, если есть.
        let proprietary: OBDProfile?

        /// Порядок исполнения: сначала производительский (больше данных), затем база.
        var ordered: [OBDProfile] { [proprietary, standard].compactMap { $0 } }
    }

    /// Возвращает подходящие профили по убыванию приоритета.
    static func matches(_ profiles: [OBDProfile], to vehicle: VehicleDescriptor) -> [OBDProfile] {
        profiles
            .filter { $0.match.matches(vehicle) }
            .sorted { $0.priority > $1.priority }
    }

    /// Выбирает стандартный (приоритет 0) и лучший производительский профиль.
    /// Стандартным считается профиль с пустыми критериями подбора.
    static func select(from profiles: [OBDProfile], for vehicle: VehicleDescriptor) -> Selection {
        let applicable = matches(profiles, to: vehicle)
        let standard = applicable.first { $0.match.isWildcard }
        let proprietary = applicable.first { !$0.match.isWildcard }
        return Selection(standard: standard, proprietary: proprietary)
    }
}

// MARK: - Matching rules

extension ProfileMatch {
    /// Профиль без критериев подходит любой машине — это базовый (стандартный).
    var isWildcard: Bool {
        brands == nil && models == nil && fuelTypes == nil && years == nil && vinWMI == nil
    }

    /// Все заданные критерии должны выполняться (логическое «И»);
    /// незаданные критерии считаются выполненными.
    func matches(_ vehicle: VehicleDescriptor) -> Bool {
        if let brands {
            guard let brand = vehicle.brand?.lowercased(),
                  brands.map({ $0.lowercased() }).contains(brand) else { return false }
        }
        if let models {
            guard let model = vehicle.model?.lowercased(),
                  models.map({ $0.lowercased() }).contains(model) else { return false }
        }
        if let fuelTypes {
            guard let fuel = vehicle.fuelType?.lowercased(),
                  fuelTypes.map({ $0.lowercased() }).contains(fuel) else { return false }
        }
        if let years {
            guard let year = vehicle.year else { return false }
            if let from = years.from, year < from { return false }
            if let to = years.to, year > to { return false }
        }
        if let vinWMI {
            guard let wmi = vehicle.wmi,
                  vinWMI.map({ $0.uppercased() }).contains(wmi) else { return false }
        }
        return true
    }
}
