import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation
import SwiftDiagnostics

public struct LocalizeMacro: DeclarationMacro {
    public static func expansion<Node: FreestandingMacroExpansionSyntax, Context: MacroExpansionContext>(of node: Node, in context: Context) throws -> [DeclSyntax] {
        guard let stringVariableName = node.stringName?.description.lowercasedFirst else {
            let error = Diagnostic(
                node: node._syntaxNode,
                message: LocalizeFeatureDiagnostic.noStringName
            )
            context.diagnose(error)
            return []
        }
        let stringKey = (
            context.lexicalContext.reversed().compactMap {
                $0.as(EnumDeclSyntax.self)?.name.trimmed.description
            } +
            [stringVariableName]
        ).joined(separator: ".")

        return [
            """
            static var \(raw: stringVariableName): String {
                String(localized: "\(raw: stringKey)", bundle: .module)
            }
            """
        ]
    }
}

@main
struct LocalizeMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LocalizeMacro.self
    ]
}

extension FreestandingMacroExpansionSyntax {
    var stringName: SyntaxProtocol? {
        arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first
    }
}

enum LocalizeFeatureDiagnostic: String, DiagnosticMessage {
    case noStringName

    var severity: DiagnosticSeverity { return .error }

    var message: String {
        switch self {
        case .noStringName:
            return "Must specify string name"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "AALocalizeMacros", id: rawValue)
    }
}

extension StringProtocol {
    var lowercasedFirst: String {
        prefix(1).lowercased() + dropFirst()
    }
}
