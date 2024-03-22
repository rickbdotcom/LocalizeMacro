import LocalizeMacro
import Foundation

extension Bundle {
    static var module: Bundle? { nil }
}

enum L10n {
    enum CommonUI {
        #Localize("country")
    }
}
