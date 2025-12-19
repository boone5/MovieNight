import SwiftUI

// MARK: - Preview Sections

struct ColorPreview: View {
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .frame(height: 50)

            Text(name)
                .font(.caption)
        }
    }
}

struct BackgroundPreview: View {
    let name: String
    let background: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(background)
            .frame(height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .overlay(
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            )
    }
}

struct TypographyPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Large Title")
                .font(.montserrat(size: 34))
            Text("Section Title")
                .font(.montserrat(size: 28, weight: .semibold))
            Text("Headline – Open Sans Semibold")
                .font(.openSans(size: 17, weight: .semibold))
            Text("Body – Open Sans Regular. This is what longer descriptions and reviews will look like in Pop'n.")
                .font(.openSans(size: 17))
            Text("Caption / Metadata")
                .font(.openSans(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Main Design System Preview

struct DesignSystemPreview: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // MARK: Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Brand Colors")
                        .font(.montserrat(size: 28))

                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                        ColorPreview(name: "Pop Red", color: .popRed)
                        ColorPreview(name: "Deep Red", color: .deepRed)
                        ColorPreview(name: "Gold", color: .goldPopcorn)
                        ColorPreview(name: "Buttercream", color: .buttercream)
                        ColorPreview(name: "Ivory", color: .ivoryWhite)
                        ColorPreview(name: "Cinema Gray", color: .cinemaGray)
                    }
                }

                // MARK: Backgrounds
                VStack(alignment: .leading, spacing: 12) {
                    Text("Backgrounds")
                        .font(.montserrat(size: 28))

                    BackgroundPreview(name: "Primary", background: .background)
                    BackgroundPreview(name: "Card", background: .card)
                }

                // MARK: Typography
                VStack(alignment: .leading, spacing: 12) {
                    Text("Typography")
                        .font(.montserrat(size: 28))
                    TypographyPreview()
                }
            }
            .padding()
            .background(Color.background)
        }
    }
}

#Preview {
    DesignSystemPreview()
        .loadCustomFonts()
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
