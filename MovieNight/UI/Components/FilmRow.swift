//
//  MockCustomModals2.swift
//  MovieNight
//
//  Created by Boone on 7/16/24.
//

import SwiftUI
import SwiftUITrackableScrollView

struct FilmRow: View {
    public var items: [ResponseType]

    @Binding public var isExpanded: Bool
    @Binding public var selectedFilm: SelectedFilm?

    var namespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.id) { film in
                    if selectedFilm?.id == film.id, isExpanded {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.clear)
                            .frame(width: 175, height: 250)
                    } else {
                        filmRowCell(film: film)
                    }
                }
            }
            .padding([.leading, .trailing], 15)
        }
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
    }

    @ViewBuilder
    private func filmRowCell(film: ResponseType) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .matchedGeometryEffect(id: "background" + String(film.id), in: namespace)
                .foregroundStyle(.clear)
                .frame(width: 175, height: 250)

            ThumbnailView(
                url: film.posterPath,
                id: film.id,
                width: 175,
                height: 250,
                namespace: namespace
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded = true
                    selectedFilm = SelectedFilm(id: film.id, type: film)
                }
            }
            .shadow(radius: 4, y: 5)

            Circle()
                .matchedGeometryEffect(id: "info" + String(film.id), in: namespace)
                .frame(width: 50, height: 20)
                .foregroundStyle(.clear)
                .padding([.bottom, .trailing], 15)
        }
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
