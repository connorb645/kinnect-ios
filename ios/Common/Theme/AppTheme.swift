import SwiftUI
import Observation

/// Global, observable theme that can be injected into the environment
/// and updated anywhere to reflect across the app.
@Observable
final class AppTheme {
    enum Mode: Equatable {
        case system
        case light
        case dark
    }

    struct Palette: Equatable {
        var primary: Color
        var secondary: Color
        var accent: Color
    }

    // Current selection mode
    var mode: Mode = .system

    // Editable palettes (provide sensible defaults)
    var light = Palette(
        primary: Color(red: 0.10, green: 0.10, blue: 0.12),
        secondary: Color(red: 0.46, green: 0.48, blue: 0.52),
        accent: .blue
    )

    var dark = Palette(
        primary: Color(red: 0.94, green: 0.95, blue: 0.96),
        secondary: Color(red: 0.66, green: 0.68, blue: 0.72),
        accent: .teal
    )

    func palette(for colorScheme: ColorScheme) -> Palette {
        switch mode {
        case .system:
            return colorScheme == .dark ? dark : light
        case .light:
            return light
        case .dark:
            return dark
        }
    }

    // MARK: - Mutators

    func setMode(_ newMode: Mode) { mode = newMode }

    func setAccent(_ color: Color, forDarkMode: Bool? = nil) {
        if let forDark = forDarkMode {
            if forDark { dark.accent = color } else { light.accent = color }
        } else {
            light.accent = color
            dark.accent = color
        }
    }

    func setPrimary(_ color: Color, forDarkMode: Bool? = nil) {
        if let forDark = forDarkMode {
            if forDark { dark.primary = color } else { light.primary = color }
        } else {
            light.primary = color
            dark.primary = color
        }
    }

    func setSecondary(_ color: Color, forDarkMode: Bool? = nil) {
        if let forDark = forDarkMode {
            if forDark { dark.secondary = color } else { light.secondary = color }
        } else {
            light.secondary = color
            dark.secondary = color
        }
    }
}

