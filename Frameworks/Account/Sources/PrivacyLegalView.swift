import SwiftUI
import UI

public struct PrivacyLegalView: View {
    @AppStorage("privacy.shareCrashReports") private var shareCrashReports: Bool = true
    @AppStorage("privacy.shareAnalytics") private var shareAnalytics: Bool = false

    @State private var showExportAlert = false
    @State private var showDeleteConfirm = false

    private let privacyPolicyURL = URL(string: "https://example.com/privacy") // TODO: Replace with your real privacy policy URL

    public init() {}

    public var body: some View {
        BackgroundColorView {
            List {
                Group {
                    Section("Privacy") {
                        Toggle(isOn: $shareCrashReports) {
                            Label("Share Crash Reports", systemImage: "exclamationmark.triangle")
                                .font(.openSans(size: 16))
                        }
                        .font(.openSans(size: 16))
                        .tint(.popRed)
                        .listRow(isFirst: true)

                        Toggle(isOn: $shareAnalytics) {
                            Label("Share Anonymous Analytics", systemImage: "chart.bar")
                                .font(.openSans(size: 16))
                        }
                        .font(.openSans(size: 16))
                        .tint(.popRed)
                        .listRow()

                        VStack {
                            Divider()
                            Text("We respect your privacy. Analytics are anonymous and help us improve. You can opt out at any time.")
                                .font(.openSans(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .listRow(isLast: true, disableTopPadding: true)
                    }
                    .font(.openSans(size: 16, weight: .semibold))

                    Section("Your Data") {
                        Button {
                            showExportAlert = true
                        } label: {
                            Label("Export My Data", systemImage: "square.and.arrow.up")
                                .font(.openSans(size: 16))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                        .listRow(isFirst: true)

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .font(.openSans(size: 16))
                        }
                        .buttonStyle(.plain)
                        .listRow(isLast: true)
                    }
                    .font(.openSans(size: 16, weight: .semibold))

                    if let privacyPolicyURL {
                        Section("Legal") {
                            Link(destination: privacyPolicyURL) {
                                Label("Privacy Policy", systemImage: "doc.text")
                                    .font(.openSans(size: 16))
                                    .foregroundStyle(.primary)
                            }
                            .listRow(isFirst: true, isLast: true)
                        }
                        .font(.openSans(size: 16, weight: .semibold))
                    }
                }
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: PLayout.horizontalMarginPadding, bottom: 0, trailing: PLayout.horizontalMarginPadding))
            }
            .listStyle(.plain)
            .foregroundStyle(.primary)
            .navigationTitle("Privacy & Legal")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Data Export", isPresented: $showExportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We'll prepare a copy of your data and notify you when it's ready to download.")
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {}
            } message: {
                Text("This action is permanent and will remove your account and data from Pop'n. You may be asked to verify your identity.")
            }
        }
    }
}

extension View {
    func listRow(isFirst: Bool = false, isLast: Bool = false, disableTopPadding: Bool = false) -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, disableTopPadding ? .bottom : .vertical]).background {
            UnevenRoundedRectangle(
                topLeadingRadius: isFirst ? 12 : 0,
                bottomLeadingRadius: isLast ? 12 : 0,
                bottomTrailingRadius: isLast ? 12 : 0,
                topTrailingRadius: isFirst ? 12 : 0
            )
            .fill(.thinMaterial)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyLegalView()
    }
    .loadCustomFonts()
}
