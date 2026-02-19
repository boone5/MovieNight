//
//  AccountLandingScreen.swift
//  Account
//
//  Created by Ayren King on 1/30/26.
//

import UI
import SwiftUI

public struct AccountLandingScreen: View {
    @Environment(\.dismiss) var dismiss

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    static var IS_PROFILE_SUPPORTED: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    if Self.IS_PROFILE_SUPPORTED {
                        ProfileInformationView()
                            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                    }

                    if Self.IS_PROFILE_SUPPORTED {
                        AccountRow(icon: "pencil", title: "Edit Profile") {

                        }
                    }

                    AccountRow(icon: "bell", title: "Notifications") {
                        NotificationsSettingsView()
                    }

                    AccountRow(icon: "lock.shield", title: "Privacy & Legal") {
                        PrivacyLegalView()
                    }
                }

                Section {
                    AccountRow(icon: "questionmark.circle", title: "Contact Support") {
                        ContactSupportView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .title) {
                    Text("Account")
                        .font(.montserrat(size: 18, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)

            .safeAreaInset(edge: .bottom, spacing: 8) {
                Text("App Version \(appVersion)")
                    .foregroundStyle(.secondary)
                    .font(.openSans(size: 12, weight: .medium))
            }
        }
    }
}

private struct ProfileInformationView: View {
    @AppStorage("account.selectedAvatar") private var selectedAvatar: String = "person.fill"

    @State private var isShowingAvatarSheet = false
    @State private var tempSelectedAvatar: String = "person.fill"

    var body: some View {
        HStack {
            VStack {
                // Predefined avatar options, similar to GitHub or StackOverflow
                Circle()
                    .fill(.thinMaterial)
                    .stroke(.primary)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: selectedAvatar)
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(.primary)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            tempSelectedAvatar = selectedAvatar
                            isShowingAvatarSheet = true
                        } label: {
                            Image(systemName: "arrow.trianglehead.2.counterclockwise")
                                .font(.system(size: 8, weight: .regular))
                                .padding(4)
                                .background {
                                    Circle()
                                        .fill(Color.background)
                                        .stroke(.primary.opacity(0.5))
                                }
                        }
                        .buttonStyle(.plain)
                    }

            }
            VStack {
                // User's display name, editable (can be used to search for friends besides unique username)
                Text("Display Name")
                    .font(.montserrat(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.primary)

                // User's unique username (non-editable)
                Text("@username")
                    .font(.openSans(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $isShowingAvatarSheet) {
            AvatarPickerSheet(selection: $tempSelectedAvatar) {
                selectedAvatar = tempSelectedAvatar
            }
        }
    }
}

private struct AccountRow<Destination: View>: View {
    var icon: String
    var title: String
    var destination: Destination

    init(
        icon: String,
        title: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.icon = icon
        self.title = title
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(title)
                .font(.openSans(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .contentShape(.rect)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
    }
}

#Preview {
    AccountLandingScreen()
        .loadCustomFonts()
}
