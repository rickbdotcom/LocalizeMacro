@freestanding(declaration, names: arbitrary)
public macro Localize(_ string: String) = #externalMacro(module: "LocalizeMacroMacros", type: "LocalizeMacro")
