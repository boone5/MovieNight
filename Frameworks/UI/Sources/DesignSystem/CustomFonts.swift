//
//  CustomFonts.swift
//  UI
//
//  Created by Ayren King on 12/17/25.
//

import SwiftUI

extension Font {
    public static func montserrat(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("Montserrat", size: size).weight(weight)
    }

    public static func openSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Open Sans", size: size).weight(weight)
    }
}

public enum CustomFonts {
    /// Registers all bundled fonts in the Pop UI framework.
    /// Safe to call multiple times.
    public static func register() {
        guard let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { return }
        fontURLs.forEach { url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }

        let registeredFonts = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
            .filter { $0.contains("Montserrat") || $0.contains("Open Sans") }
    }
}

extension View {
    /// Attach this to any Xcode Preview's view to have custom fonts displayed.
    /// Note: Not needed for the app itself, only for previews.
    public func loadCustomFonts() -> some View {
        CustomFonts.register()
        return self
    }
}
