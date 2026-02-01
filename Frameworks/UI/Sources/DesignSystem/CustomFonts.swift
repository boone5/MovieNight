//
//  CustomFonts.swift
//  UI
//
//  Created by Ayren King on 12/17/25.
//

import SwiftUI

extension Font {
    /// Returns a Montserrat font with the given size and weight.
    /// Defaults to `.bold` weight.
    public static func montserrat(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("Montserrat", size: size).weight(weight)
    }

    /// Returns an Open Sans font with the given size and weight.
    /// Defaults to `.regular` weight.
    public static func openSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Open Sans", size: size).weight(weight)
    }
}

extension UIFont {
    /// Returns a Montserrat font for UIKit. Falls back to the system font
    /// when the font is not registered or unavailable.
    public static func montserrat(size: CGFloat) -> UIFont {
        UIFont(name: "Montserrat", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Returns an Open Sans font for UIKit. Falls back to the system font
    /// when the font is not registered or unavailable.
    public static func openSans(size: CGFloat) -> UIFont {
        UIFont(name: "Open Sans", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

public enum CustomFonts {
    /// Registers all bundled fonts in the Pop UI framework.
    ///
    /// Implementation details:
    /// - Enumerates all `.ttf` resources from `Bundle.module`.
    /// - Registers each font URL using `CTFontManagerRegisterFontsForURL` scoped to the process.
    /// - Safe to call multiple times (re-registration is ignored by CoreText).
    public static func register() {
        guard let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        fontURLs.forEach { url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension View {
    /// Registers custom fonts for Xcode Previews and returns `self`.
    ///
    /// Call this from a preview body to ensure the preview process has
    /// access to the bundled fonts. Not required in the running application
    /// as the framework can register fonts on launch.
    public func loadCustomFonts() -> some View {
        CustomFonts.register()
        return self
    }
}
