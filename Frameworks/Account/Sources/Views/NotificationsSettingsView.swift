//
//  NotificationsSettingsView.swift
//  Account
//
//  Created by Ayren King on 2026/02/05.
//

import SwiftUI
import UserNotifications
import UI
import ActivityKit

/// Settings screen for notification preferences.
public struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        BackgroundColorView {
            List {
                Group {
                    Section("Permissions") {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Local Notifications")
                                    .font(.openSans(size: 16, weight: .medium))
                                    .foregroundStyle(.primary)

                                Text(viewModel.authorizationText)
                                    .font(.openSans(size: 13))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if viewModel.isAuthorized {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                            } else if viewModel.isDenied {
                                Button("Open Settings") {
                                    viewModel.openSettings()
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button("Request") {
                                    viewModel.requestPermission()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listRow(isFirst: true, isLast: true)
                    }

                    Section("Local Notifications") {
                        HStack {
                            Toggle(isOn: $viewModel.localEnabled) {
                                Text("Enable Local Notifications")
                                    .font(.openSans(size: 16, weight: .regular))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Spacer()
                        }
                        .listRow(isFirst: true, isLast: true)
                    }

                    Section("Live Activities") {
                        HStack {
                            Toggle(isOn: $viewModel.liveActivitiesEnabled) {
                                Text("Enable Live Activities")
                                    .font(.openSans(size: 16, weight: .regular))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Spacer()
                        }
                        .listRow(isFirst: true, isLast: true)
                    }

                    Section("Server Notifications") {
                        HStack {
                            Toggle(isOn: $viewModel.serverNotificationsEnabled) {
                                Text("Enable server push notifications")
                                    .font(.openSans(size: 16, weight: .regular))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            Spacer()
                        }
                        .listRow(isFirst: true)

                        VStack {
                            Divider()
                            Text("Server notifications require an account and a valid device token. If enabled, the server may send breaking alerts and recommendation nudges.")
                                .font(.openSans(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .listRow(isFirst: false, isLast: true, disableTopPadding: true)
                    }

                    // Footer / troubleshooting
                    Section("Troubleshooting") {
                        Text("If you’re not receiving notifications, ensure permissions are enabled in Settings and that server notifications are configured for your account.")
                            .font(.openSans(size: 13))
                            .foregroundStyle(.secondary)
                            .listRow(isFirst: true, isLast: true)
                    }

                }
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: PLayout.horizontalMarginPadding, bottom: 0, trailing: PLayout.horizontalMarginPadding))
            }
            .listStyle(.plain)
            .tint(Color.popRed)
            .foregroundStyle(.primary)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.refreshPermissions()
        }
    }
}

fileprivate extension NotificationsSettingsView {

    // TODO: Migrate to TCA
    @MainActor
    final class ViewModel: ObservableObject {
        @AppStorage("notifications.localEnabled") var localEnabled: Bool = true
        @AppStorage("notifications.liveActivitiesEnabled") var liveActivitiesEnabled: Bool = false
        @AppStorage("notifications.serverEnabled") var serverNotificationsEnabled: Bool = false

        @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

        var isAuthorized: Bool { authorizationStatus == .authorized }
        var isDenied: Bool { authorizationStatus == .denied }

        var authorizationText: String {
            switch authorizationStatus {
            case .authorized:
                return "Allowed — alerts, badges, sounds"
            case .denied:
                return "Denied — open Settings to enable"
            case .provisional:
                return "Provisionally allowed"
            case .ephemeral:
                return "Ephemeral authorization"
            case .notDetermined:
                return "Not requested"
            @unknown default:
                return "Unknown"
            }
        }

        init() {}

        func refreshPermissions() async {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                authorizationStatus = settings.authorizationStatus
            }
        }

        func requestPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] _, _ in
                DispatchQueue.main.async {
                    self?.refreshPermissionsSilently()
                }
            }
        }

        private func refreshPermissionsSilently() {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    self?.authorizationStatus = settings.authorizationStatus
                }
            }
        }

        func openSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
            .loadCustomFonts()
    }
}
