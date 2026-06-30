//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

final class GlobalDefinitions {
    static let domain = "https://carconnect.bloomupapps.com"
    static let accessToken = "1E0fCaZs7zvSEZoXPP"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "zbRimnpY41TJhMpd"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let lifetime = "utility.app.obd2.lt20"
        static let monthly = "utility.app.obd2.sub10"
    }
}
