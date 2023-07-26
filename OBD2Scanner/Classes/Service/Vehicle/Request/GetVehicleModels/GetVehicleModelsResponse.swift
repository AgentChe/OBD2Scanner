//
//  GetVehicleModelsResponse.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 21.07.2023.
//

enum GetVehicleModelsResponse {
    static func map(from response: Any) -> [String] {
        guard
            let json = response as? [String: Any],
            let output = json["output"] as? String,
            let decodedData = Data(base64Encoded: output),
            let decodedString = String(data: decodedData, encoding: .utf8),
            let json = XOREncryption.toJSON(decodedString, key: GlobalDefinitions.xorKey),
            let body = json["body"] as? [String: Any],
            let models = body["models"] as? [String]
        else {
            return []
        }
        
        return models
    }
}
