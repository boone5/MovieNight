//
//  SettingsValue+Shared.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/5/25.
//

import ProjectDescription

public extension SettingValue {
    /// Additional linker flags for the project.
    static var otherLDFlags: SettingValue {
        .string("$(inherited) -ObjC")
    }
}
