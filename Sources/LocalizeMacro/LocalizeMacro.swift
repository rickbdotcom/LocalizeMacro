@freestanding(declaration, names: arbitrary)
public macro Localize(_ stringKey: String, arguments: Any...) = #externalMacro(module: "LocalizeMacroMacros", type: "LocalizeMacro")
