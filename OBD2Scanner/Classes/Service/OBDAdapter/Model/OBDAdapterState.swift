//
//  OBDAdapterState.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 24.07.2023.
//

enum OBDAdapterState {
    case unknown
    case notFound
    case error
    case discovering
    case present
    case initializing
    case ready
    case ignitionOff
    case connected
    case unsupportedProtocol
    case gone
    
    init(_ state: OBD2AdapterState) {
        switch state {
        case OBD2AdapterStateUnknown:
            self = .unknown
        case OBD2AdapterStateNotFound:
            self = .notFound
        case OBD2AdapterStateError:
            self = .error
        case OBD2AdapterStateDiscovering:
            self = .discovering
        case OBD2AdapterStatePresent:
            self = .present
        case OBD2AdapterStateInitializing:
            self = .initializing
        case OBD2AdapterStateReady:
            self = .ready
        case OBD2AdapterStateIgnitionOff:
            self = .ignitionOff
        case OBD2AdapterStateConnected:
            self = .connected
        case OBD2AdapterStateNotFound:
            self = .notFound
        case OBD2AdapterStateUnsupportedProtocol:
            self = .unsupportedProtocol
        case OBD2AdapterStateGone:
            self = .gone
        default:
            self = .unknown
        }
    }
}
