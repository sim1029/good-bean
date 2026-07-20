import SwiftUI

// MARK: - Color Palette
extension Color {
    static let gbBackground    = Color.dynamic(light: 0xFAFAF8, dark: 0x111009)
    static let gbSurface       = Color.dynamic(light: 0xF2EDE8, dark: 0x1E1B17)
    static let gbTextPrimary   = Color.dynamic(light: 0x1A1614, dark: 0xF5F0EB)
    static let gbTextSecondary = Color.dynamic(light: 0x6B5F57, dark: 0x9C8E84)
    static let gbTextTertiary  = Color.dynamic(light: 0xA8998F, dark: 0x6B5F57)
    static let gbAccent        = Color.dynamic(light: 0xB8712A, dark: 0xD4924D)
    static let gbSeparator     = Color.dynamic(light: 0xE8E0D8, dark: 0x2A251F)

    // Cool tones reserved for frozen/defrosted bean statuses (the only
    // non-warm colors in the system — kept muted to fit the palette).
    static let gbStatusFrozen    = Color.dynamic(light: 0x3A7CA5, dark: 0x74B3D8)
    static let gbStatusDefrosted = Color.dynamic(light: 0x4C9A94, dark: 0x7FC9C0)

    private static func dynamic(light: UInt, dark: UInt) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark
            ? UIColor(hex: dark) : UIColor(hex: light) })
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: alpha
        )
    }
}

// MARK: - Bean Status Color
extension BeanStatus {
    /// Themed color for this status (used by badges and menus).
    var color: Color {
        switch self {
        case .active:    return .gbAccent
        case .frozen:    return .gbStatusFrozen
        case .defrosted: return .gbStatusDefrosted
        case .archived:  return .gbTextSecondary
        case .depleted:  return .gbTextTertiary
        }
    }
}

// MARK: - Typography / Spacing / Radius
enum Theme {
    enum Font {
        static let display   = SwiftUI.Font.system(size: 28, weight: .bold,     design: .default)
        static let title     = SwiftUI.Font.system(size: 20, weight: .semibold, design: .default)
        static let headline  = SwiftUI.Font.system(size: 16, weight: .medium,   design: .default)
        static let body      = SwiftUI.Font.system(size: 14, weight: .regular,  design: .default)
        static let caption   = SwiftUI.Font.system(size: 12, weight: .regular,  design: .default)
        static let data      = SwiftUI.Font.system(size: 14, weight: .medium,   design: .monospaced)
        static let dataLarge = SwiftUI.Font.system(size: 22, weight: .bold,     design: .monospaced)
    }

    enum Spacing {
        static let xs: CGFloat  =  4
        static let sm: CGFloat  =  8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
    }
}

// MARK: - Card Style
struct GBCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.gbSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .strokeBorder(Color.gbSeparator, lineWidth: 1)
            )
    }
}

extension View {
    func gbCardStyle() -> some View { modifier(GBCardStyle()) }
}

// MARK: - Button Styles
struct GBPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.body.weight(.medium))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(Color.gbAccent.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }
}

struct GBSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.body.weight(.medium))
            .foregroundStyle(Color.gbAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(Color.gbAccent.opacity(configuration.isPressed ? 0.08 : 0))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .strokeBorder(Color.gbAccent, lineWidth: 1)
            )
    }
}

struct GBRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.gbTextPrimary)
            .padding(Theme.Spacing.md)
            .background(Color.gbSurface.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }
}
