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
        Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String ?? ""
    }

    static var IS_PROFILE_SUPPORTED: Bool {
        #if DEBUG
        false
        #else
        false
        #endif
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            BackgroundColorView {
                ScrollView {
                    VStack {
                        NavigationHeader(
                            title: "Account",
                            trailingButtons: [
                                .init(systemImage: "xmark", action: {
                                    dismiss()
                                })
                            ]
                        )

                        if Self.IS_PROFILE_SUPPORTED {
                            ProfileInformationView()
                        }

                        VStack(spacing: 0) {
                            if Self.IS_PROFILE_SUPPORTED {
                                AccountRow(icon: "pencil", title: "Edit Profile", isFirst: true) {

                                }
                            }

                            AccountRow(icon: "bell", title: "Notifications", isFirst: !Self.IS_PROFILE_SUPPORTED) {
                                NotificationsSettingsView()
                            }

                            AccountRow(icon: "lock.shield", title: "Privacy & Legal", isLast: true) {
                                PrivacyLegalView()
                            }
                            .padding(.bottom, 24)

                            AccountRow(icon: "info.circle", title: "About Us", isFirst: true) {
                                AboutUsView()
                            }

                            AccountRow(icon: "questionmark.circle", title: "Contact Support", isLast: true) {
                                ContactSupportView()
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal, PLayout.horizontalMarginPadding)
                }
                .scrollBounceBehavior(.basedOnSize)
                .safeAreaInset(edge: .bottom, spacing: 8) {
                    Text("App Version \(appVersion)")
                        .foregroundStyle(.secondary)
                        .font(.openSans(size: 12, weight: .medium))
                }
            }
        }
    }
}

private struct ProfileInformationView: View {
    @AppStorage("account.selectedAvatar") private var selectedAvatar: String = "person.fill"

    @State private var isShowingAvatarSheet = false
    @State private var tempSelectedAvatar: String = "person.fill"

    var body: some View {
        VStack {
            // Predefined avatar options, similar to GitHub or StackOverflow
            Circle()
                .fill(.thinMaterial)
                .stroke(.primary)
                .frame(width: 100, height: 100)
                .overlay {
                    Image(systemName: selectedAvatar)
                        .font(.system(size: 40, weight: .regular))
                        .foregroundStyle(.primary)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        tempSelectedAvatar = selectedAvatar
                        isShowingAvatarSheet = true
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                            .padding(4)
                            .background {
                                Circle()
                                    .fill(Color.background)
                                    .stroke(.primary.opacity(0.5))
                            }
                    }
                    .buttonStyle(.plain)
                }

            // User's display name, editable (can be used to search for friends besides unique username)
            Text("Display Name")
                .font(.montserrat(size: 24, weight: .medium))
                .foregroundStyle(.primary)

            // User's unique username (non-editable)
            Text("@username")
                .font(.openSans(size: 16))
                .foregroundStyle(.secondary)

            Divider()
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
    var isFirst: Bool
    var isLast: Bool
    var destination: Destination

    init(
        icon: String,
        title: String,
        isFirst: Bool = false,
        isLast: Bool = false,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.icon = icon
        self.title = title
        self.isFirst = isFirst
        self.isLast = isLast
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    .padding(6)
                    .background(.secondary.opacity(0.1), in: .circle)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.openSans(size: 16, weight: .regular))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.primary)
            .padding()
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: isFirst ? 12 : 0,
                    bottomLeadingRadius: isLast ? 12 : 0,
                    bottomTrailingRadius: isLast ? 12 : 0,
                    topTrailingRadius: isFirst ? 12 : 0
                )
                .fill(.thinMaterial)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountLandingScreen()
        .loadCustomFonts()
}
