import SwiftUI
import UI

public struct AboutUsView: View {

    public init() {}

    public var body: some View {
        BackgroundColorView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App mark
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.thinMaterial)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle()
                                        .stroke(.primary.opacity(0.15), lineWidth: 1)
                                )
                            Image(systemName: "popcorn.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.primary)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pop'n")
                                .font(.montserrat(size: 28, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Discover, rate, and pick what to watch.")
                                .font(.openSans(size: 16))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    // Description from README
                    Text("Pop'n helps you discover upcoming movies and TV shows, rate and favorite titles, build a personal library, and pick something to watch when indecision strikes.")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Pop'n is a passion project. Thanks for supporting indie software!")
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    // Highlights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Highlights")
                            .font(.montserrat(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)

                        FeatureRow(title: "Discover upcoming movies and TV shows", systemImage: "sparkles")
                        FeatureRow(title: "Rate, favorite, and track what you've watched", systemImage: "star.fill")
                        FeatureRow(title: "Build a personal library", systemImage: "books.vertical.fill")
                        FeatureRow(title: "Let Pop'n help when you can't decide", systemImage: "questionmark.circle")
                    }
                    .padding(.vertical, 6)
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
                .padding(.bottom, PLayout.bottomMarginPadding)
            }
            .navigationTitle("About Pop'n")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct FeatureRow: View {
    var title: String
    var systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 22)
            Text(title)
                .font(.openSans(size: 16))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        AboutUsView()
    }
    .loadCustomFonts()
}
