//
//  Weak.swift
//  OBD2Scanner
//
//  Created by Андрей Чернышев on 23.08.2026.
//

import Foundation

final class Weak<T> {
    private weak var object: AnyObject?

    init(_ object: AnyObject?) {
        self.object = object
    }

    var weak: T? {
        object as? T
    }
}
