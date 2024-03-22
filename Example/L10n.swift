//
//  L10n.swift
//  LocalizeExample
//
//  Created by Burgess, Rick (CHICO-C) on 3/22/24.
//

import Foundation
import LocalizeMacro

enum L10n {
    #Localize("hello")
    #Localize("things", arguments: ("people", Int), ("geese", Int), String, Int)
}

extension Bundle {
    static var module: Bundle? { nil }
}
