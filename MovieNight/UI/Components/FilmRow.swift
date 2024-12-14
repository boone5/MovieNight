//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import SwiftUI
import SwiftUITrackableScrollView

struct FilmRow: View {
    @StateObject private var viewModel = ThumbnailView.ViewModel()

    public var items: [ResponseType]

    @Binding public var isExpanded: Bool
    @Binding public var selectedFilm: SelectedFilm?

    let namespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.id) { film in
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.clear)
                            .frame(width: 175, height: 250)
                    } else {
                        ThumbnailView(viewModel: viewModel, filmID: film.id, posterPath: film.posterPath, namespace: namespace)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    isExpanded = true
                                    selectedFilm = SelectedFilm(id: film.id, type: film, posterImage: viewModel.posterImage(for: film.posterPath))
                                }
                            }
                    }
                }
            }
            .padding([.leading, .trailing], 15)
        }
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
    }
}

extension View {
    var screenSize: CGSize {
        guard let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size else { return .zero }

        return size
    }
}

extension UIImage {
    var averageColor: UIColor {
        guard let inputImage = CIImage(image: self) else { return .black }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return .black }
        guard let outputImage = filter.outputImage else { return .blue }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
