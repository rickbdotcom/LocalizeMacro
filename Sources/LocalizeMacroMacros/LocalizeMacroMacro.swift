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

        if node.arguments.count == 1 {
            return [
            """
            static var \(raw: stringVariableName): String {
                String(localized: "\(raw: stringKey)", bundle: .module)
            }
            """
            ]
        } else {
            var argCount = 1
            let funcArgs = node.arguments.dropFirst().compactMap { arg in
                if let expr = arg.expression.as(TupleExprSyntax.self) {
                    guard expr.elements.count == 2,
                          let argName = expr.elements.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first,
                          let type = expr.elements.last?.expression.as(DeclReferenceExprSyntax.self)
                    else {
                        let error = Diagnostic(
                            node: arg._syntaxNode,
                            message: LocalizeFeatureDiagnostic.incorrectTuple
                        )
                        context.diagnose(error)
                        return nil
                    }
                    return "\(argName): \(type)"
                } else if let type = arg.expression.as(DeclReferenceExprSyntax.self) {
                    let argName = "arg\(argCount)"
                    argCount += 1
                    return "_ \(argName): \(type)"
                } else {
                    let error = Diagnostic(
                        node: arg._syntaxNode,
                        message: LocalizeFeatureDiagnostic.unsupportedType
                    )
                    context.diagnose(error)
                    return nil
                }
            }.joined(separator: ", ")

            argCount = 1
            let stringKeyArgs = node.arguments.dropFirst().compactMap { arg in
                if let expr = arg.expression.as(TupleExprSyntax.self) {
                    guard expr.elements.count == 2,
                          let argName = expr.elements.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first
                    else {
                        let error = Diagnostic(
                            node: arg._syntaxNode,
                            message: LocalizeFeatureDiagnostic.incorrectTuple
                        )
                        context.diagnose(error)
                        return nil
                    }
                    return "\\(\(argName))"
                } else if let type = arg.expression.as(DeclReferenceExprSyntax.self) {
                    let argName = "arg\(argCount)"
                    argCount += 1
                    return "\\(\(argName))"
                } else {
                    let error = Diagnostic(
                        node: arg._syntaxNode,
                        message: LocalizeFeatureDiagnostic.unsupportedType
                    )
                    context.diagnose(error)
                    return nil
                }            }.joined(separator: ", ")

            return [
            """
            static func \(raw: stringVariableName)(\(raw: funcArgs)) -> String {
                String(localized: "\(raw: stringKey)(\(raw: stringKeyArgs))", bundle: .module)
            }
            """
            ]
        }
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
    case unsupportedType
    case incorrectTuple

    var severity: DiagnosticSeverity { return .error }

    var message: String {
        switch self {
        case .noStringName:
            return "Must specify string name"
        case .unsupportedType:
            return "Unsupported Type"
        case .incorrectTuple:
            return "Tuple must be consistent of two elements (String, Type)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "LocalizeMacros", id: rawValue)
    }
}

extension StringProtocol {
    var lowercasedFirst: String {
        prefix(1).lowercased() + dropFirst()
    }
}
