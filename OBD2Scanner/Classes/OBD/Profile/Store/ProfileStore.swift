//
//  ProfileStore.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.07.2026.
//

import Foundation

/// Источник профилей. Пока читает JSON из бандла приложения; позже тем же
/// интерфейсом можно подложить загрузку с сервера — движок этого не заметит.
final class ProfileStore {
    private(set) var profiles: [OBDProfile] = []

    /// Профили, которые не удалось разобрать: имя файла → ошибка. Для диагностики.
    private(set) var failures: [String: Error] = [:]

    /// Загружает все `*.json` из указанного бандла, оставляя валидные профили
    /// с поддерживаемой версией схемы. Неотносящиеся к профилям JSON (если есть)
    /// не пройдут строгий разбор и будут просто пропущены.
    func loadFromBundle(_ bundle: Bundle = .main, subdirectory: String? = nil) {
        profiles = []
        failures = [:]

        guard let urls = bundle.urls(forResourcesWithExtension: "json",
                                     subdirectory: subdirectory) else {
            return
        }

        let decoder = JSONDecoder()
        for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            do {
                let data = try Data(contentsOf: url)
                let profile = try decoder.decode(OBDProfile.self, from: data)
                guard profile.schemaVersion <= OBDProfile.currentSchemaVersion else {
                    failures[url.lastPathComponent] = ProfileStoreError.unsupportedSchema(profile.schemaVersion)
                    continue
                }
                profiles.append(profile)
            } catch {
                // Строгий разбор отсеивает посторонние JSON — это ожидаемо.
                failures[url.lastPathComponent] = error
            }
        }
    }
}

enum ProfileStoreError: Error {
    case unsupportedSchema(Int)
}
