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
    @AppStorage("account.selectedAvatar") private var selectedAvatar: String = "person.fill"
    @AppStorage("app.themeMode") private var themeModeRaw: String = ThemeMode.system.rawValue
    private var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRaw) ?? .system
    }
    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { themeMode },
            set: { themeModeRaw = $0.rawValue }
        )
    }
    @State private var isShowingAvatarSheet = false
    @State private var tempSelectedAvatar: String = "person.fill"

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String ?? ""
    }

    public init() {}

    public var body: some View {
        NavigationStack {
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
                    
                    VStack(spacing: 0) {
                        AccountRow(icon: "pencil", title: "Edit Profile", isFirst: true) {

                        }
                        
                        AccountRow(icon: "bell", title: "Notifications") {
                            
                        }
                        
                        AccountRow(icon: "lock.shield", title: "Privacy & Security") {
                            
                        }
                        
                        AccountThemeRow(icon: "paintbrush", title: "Theme", isLast: true, selection: themeBinding)
                        .padding(.bottom, 24)

                        AccountRow(icon: "info.circle", title: "About Us", isFirst: true) {

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
        }
        .safeAreaInset(edge: .bottom, spacing: 8) {
            Text("App Version \(appVersion)")
                .foregroundStyle(.secondary)
                .font(.openSans(size: 12, weight: .medium))
        }
        .sheet(isPresented: $isShowingAvatarSheet) {
            AvatarPickerSheet(selection: $tempSelectedAvatar) {
                selectedAvatar = tempSelectedAvatar
            }
        }
    }
}

private struct AccountRow<Destination:View>: View {
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
        @ViewBuilder destination:  @escaping () -> Destination
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

public enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

private struct AccountThemeRow: View {
    var icon: String
    var title: String
    var isFirst: Bool = false
    var isLast: Bool = false
    @Binding var selection: ThemeMode

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
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
            Picker("", selection: $selection) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            } currentValueLabel: {
                Text(selection.displayName)
                    .font(.openSans(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, -10)
            .tint(.secondary)
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
}

#Preview {
    AccountLandingScreen()
        .loadCustomFonts()
}

