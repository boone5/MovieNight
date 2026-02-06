//
//  UIWindow+Current.swift
//  UI
//
//  Created by Ayren King on 2/6/26.
//

import UIKit

extension UIWindow {
    public static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }

    public var currentSceneWidth: CGFloat? {
        windowScene?.screen.bounds.width
    }
}
