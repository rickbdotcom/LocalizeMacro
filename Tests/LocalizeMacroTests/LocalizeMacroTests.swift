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

    func testLocalizeArgumentMacro() throws {
#if canImport(LocalizeMacroMacros)
        assertMacroExpansion(
            """
            enum L10n {
                enum CommonUI {
                    #Localize("Things", arguments: ("people", Int), ("geese", Int), String, Double)
                }
            }
            """,
            expandedSource: """
            enum L10n {
                enum CommonUI {
                    static func things(people: Int, geese: Int, _ arg1: String, _ arg2: Double) -> String {
                        String(localized: "L10n.CommonUI.things(\\(people), \\(geese), \\(arg1), \\(arg2))", bundle: .module)
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
