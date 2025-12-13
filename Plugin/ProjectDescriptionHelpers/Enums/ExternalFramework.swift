//
//  ExternalFramework.swift
//  BundlePlugin
//
//  Created by Ayren King on 12/4/25.
//

public enum ExternalFramework: String {
    case composableArchitecture = "ComposableArchitecture"
    case fortuneWheel = "FortuneWheel"

    var name: String {
        rawValue
    }
}
