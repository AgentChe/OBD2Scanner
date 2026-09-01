//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://obd2.thinkaboutapps.com"
    static let accessToken = "TU9drYgOd0vBWJhqnfga4UnD"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "zbRimnpY41TJhMpd"

    static let postHogHost = "https://posthog.korrekted.com"
    static let postHogApiKey = "phc_a29Kj3MGr3nLv9NN4WLZiRyHF5mluQZaPbVgcCbIqPa"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let lifetime = "utility.app.obd2.lt20"
        static let monthly = "utility.app.obd2.sub10"
    }
}
