//
//  Error.swift
//  Lilith-Launcher
//
//  Created by 0x41c on 2022-04-22.
//

import Foundation

enum CoolError: Error {
    case withMessage(String)
}

extension CoolError: CustomStringConvertible {
    var description: String {
        switch self {
        case .withMessage(let message):
            return message
        }
    }
}
