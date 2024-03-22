import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(LocalizeMacroMacros)
import LocalizeMacroMacros

let testMacros: [String: Macro.Type] = [
    "Localize": LocalizeMacro.self,
]
#endif

final class LocalizeMacroTests: XCTestCase {
    func testLocalizeMacro() throws {
        #if canImport(LocalizeMacroMacros)
        assertMacroExpansion(
            """
            enum L10n {
                enum CommonUI {
                    #Localize("Country")
                }
            }
            """,
            expandedSource: """
            enum L10n {
                enum CommonUI {
                    static var country: String {
                        String(localized: "L10n.CommonUI.country", bundle: .module)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
