////
////  AsyncButton.swift
////  MovieNight
////
////  Created by Boone on 4/20/24.
////
//
//import SwiftUI
//
//struct AsyncButton<T: View>: View {
//    private let action: () async -> Void
//    private let label: T
//
//    @State private var task: Task<Void, Never>? = nil
//
//    var body: some View {
//        Button {
//            guard task == nil else { return }
//
//            task = Task {
//                await action()
//                task = nil
//            }
//        } label: {
//            if task != nil {
//                ProgressView()
//            } else {
//                label
//            }
//        }
//
//    }
//
//    init(action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> T) {
//        self.action = action
//        self.label = label()
//    }
//}
//
//#Preview {
//    AsyncButton {
//        print("Hello World")
//    } label: {
//        Text("Hello")
//            .foregroundStyle(.black)
//    }
//
//}
