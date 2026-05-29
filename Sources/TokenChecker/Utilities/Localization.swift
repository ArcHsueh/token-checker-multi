import Foundation

/// Look up a UI string from the app's main-bundle .lproj catalogs.
/// Single variadic entry point: zero args returns the raw localized string,
/// otherwise it is treated as a printf-style format with the given arguments.
func L(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return args.isEmpty ? format : String(format: format, arguments: args)
}
