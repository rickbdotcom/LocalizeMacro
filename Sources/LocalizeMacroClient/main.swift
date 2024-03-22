import LocalizeMacro
import Foundation

extension Bundle {
    static var module: Bundle? { nil }
}

enum L10n {
    enum CommonUI {
        #Localize("company")
        #Localize("things", arguments: ("person", Int), ("geese", String), Int, String)
    }
}
