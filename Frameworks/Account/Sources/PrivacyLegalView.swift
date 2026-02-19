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
        Form {
            Section("Privacy") {
                Toggle(isOn: $shareCrashReports) {
                    Text("Share Crash Reports")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.primary)
                }
                .font(.openSans(size: 16))
                .tint(.popRed)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Toggle(isOn: $shareAnalytics) {
                    Text("Share Anonymous Analytics")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.primary)
                }
                .font(.openSans(size: 16))
                .tint(.popRed)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Text("We respect your privacy. Analytics are anonymous and help us improve. You can opt out at any time.")
                    .font(.openSans(size: 13))
                    .foregroundStyle(.secondary)
            }
            .font(.openSans(size: 16, weight: .semibold))

            Section("Your Data") {
                Button {
                    showExportAlert = true
                } label: {
                    Text("Export My Data")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text("Delete Account")
                        .font(.openSans(size: 16))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
            .font(.openSans(size: 16, weight: .semibold))

            if let privacyPolicyURL {
                Section("Legal") {
                    Link(destination: privacyPolicyURL) {
                        Text("Privacy Policy")
                            .font(.openSans(size: 16))
                            .foregroundStyle(.primary)
                    }
                    .tint(Color.primary)
                }
                .font(.openSans(size: 16, weight: .semibold))
            }
        }
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

#Preview {
    NavigationStack {
        PrivacyLegalView()
    }
    .loadCustomFonts()
}
