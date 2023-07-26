//
//  GetVehicleImageResponse.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

import Foundation

enum GetVehicleImageResponse {
    static func map(from response: Any) -> URL? {
        guard
            let json = response as? [String: Any],
            let output = json["output"] as? String,
            let decodedData = Data(base64Encoded: output),
            let decodedString = String(data: decodedData, encoding: .utf8),
            let json = XOREncryption.toJSON(decodedString, key: GlobalDefinitions.xorKey),
            let body = json["body"] as? [String: Any],
            let onboarding = body["onboarding"] as? [String: Any],
            let preview = onboarding["preview"] as? String
        else {
            return nil
        }
        
        let path = GlobalDefinitions.vehiclesDomain + preview
        return URL(string: path)
    }
}
