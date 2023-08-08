//
//  Paygate.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 07.08.2023.
//

struct Paygate: Codable, Hashable {
    let leftOptionConfig: PaygateOptionConfig
    let rightOptionConfig: PaygateOptionConfig
}
