//
//  BlurView.swift
//  MovieNight
//
//  Created by Boone on 9/5/24.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> some UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
