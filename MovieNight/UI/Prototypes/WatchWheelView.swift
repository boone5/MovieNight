//
//  WatchWheelView.swift
//  MovieNight
//
//  Created by Boone on 3/29/25.
//

import SwiftUI

struct WheelView2: View {
    @State  var radius: CGFloat = 0
    @StateObject var viewModel = WatchWheelView.ViewModel()

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<viewModel.segmentCount, id: \.self) { index in
                        ZStack {
                            Segment(startAngle: self.angleForSegment(index), endAngle: self.angleForSegment(index + 1))
                                .fill(viewModel.colors[index % viewModel.colors.count])
                                .onAppear {
                                    let midX = geometry.frame(in: .local).midX + 40
                                    let midY = geometry.frame(in: .local).midY + 40
                                    radius = min(midX, midY)
                                }
                            Text(viewModel.names[index])
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(width: 75)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .rotationEffect(self.angleForSegment(index + 1) - Angle(degrees: 10))
                                .offset(
                                    CGSize(
                                        width: { () -> Double in
                                            let mean: Angle = (self.angleForSegment(index) + self.angleForSegment(index + 1)) / 2
                                            return radius * 0.4 * cos(mean.radians)
                                        }(),
                                        height: { () -> Double in
                                            let mean: Angle = (self.angleForSegment(index) + self.angleForSegment(index + 1)) / 2
                                            return radius * 0.4 * sin(mean.radians)
                                        }()
                                    )
                                )
                        }
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(viewModel.rotation))
                    }

                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)

                    Arrow()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(180))
                        .offset(x: 150, y: 0)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
                //                .offset(x: 10)
                .onTapGesture {
                    viewModel.spinRoulette()
                }
            }
            .padding(30)
        }
        .onAppear {
            viewModel.addFilmsToWheel(Array(watchList))
        }
    }

    func angleForSegment(_ index: Int) -> Angle {
        Angle(degrees: Double(index) / Double(viewModel.names.count) * 360)
    }
}

struct WatchWheelView: View {
    @State  var radius: CGFloat = 0
    @StateObject var viewModel = ViewModel()

    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    @FetchRequest(
        entity: Film.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Film.dateWatched, ascending: true)],
        predicate: NSPredicate(format: "collection.id == %@", FilmCollection.watchLaterID as CVarArg)
    )
    private var watchList: FetchedResults<Film>

    private var numberOfRows: Int {
        (watchList.count + 1) / 2
    }

    var body: some View {
        NavigationView {
            BackgroundColorView {
                GeometryReader { geometry in
                    VStack(alignment: .center, spacing: 0) {
                        Text("count: \(viewModel.names.count)")

                        ZStack {
                            ForEach(0..<viewModel.segmentCount, id: \.self) { index in
                                let startAngle = self.angleForSegment(index)
                                let endAngle = self.angleForSegment(index + 1)
                                let mean: Angle = (startAngle + endAngle) / 2
                                // Calculate the chord's angle using arctan2.
                                let chordAngleRadians = atan2(
                                    sin(endAngle.radians) - sin(startAngle.radians),
                                    cos(endAngle.radians) - cos(startAngle.radians)
                                )
                                let chordAngle = Angle(radians: chordAngleRadians)

                                ZStack {
                                    Segment(startAngle: startAngle, endAngle: endAngle)
                                        .fill(viewModel.colors[index % viewModel.colors.count])
                                        .onAppear {
                                            let midX = geometry.frame(in: .local).midX + 40
                                            let midY = geometry.frame(in: .local).midY + 40
                                            radius = min(midX, midY)
                                        }

                                    Text(viewModel.names[index])
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(maxWidth: 100)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .rotationEffect(chordAngle + Angle(degrees: 90))
                                        .offset(
                                            CGSize(
                                                width: radius * 0.35 * cos(mean.radians),
                                                height: radius * 0.35 * sin(mean.radians)
                                            )
                                        )
                                }
                                .frame(width: 300, height: 300)
                                .rotationEffect(.degrees(viewModel.rotation))
                            }

                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)

                            Arrow()
                                .fill(Color.gray)
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(180))
                                .offset(x: 150, y: 0)
                                .shadow(color: .gray, radius: 4, x: 2, y: 2)
                        }
                        .padding(.top, 40)
                        .onTapGesture {
                            viewModel.spinRoulette()
                        }

                        Text("Watch List")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 15)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ListView(
                            results: Array(watchList),
                            namespace: namespace,
                            isExpanded: $isExpanded,
                            selectedFilm: $selectedFilm
                        )
                        .padding(.top, 20)

                        Spacer()

//                            Grid(
//                                alignment: .center,
//                                horizontalSpacing: 30,
//                                verticalSpacing: 30
//                            ) {
//                                ForEach(0..<numberOfRows, id: \.self) { rowIdx in
//                                    GridRow {
//                                        // First cell in the row
//                                        let firstIndex = rowIdx * 2
//                                        ThumbnailView(
//                                            viewModel: .init(),
//                                            filmID: watchList[firstIndex].id,
//                                            posterPath: watchList[firstIndex].posterPath,
//                                            width: 150,
//                                            height: 225,
//                                            namespace: namespace
//                                        )
//
//                                        // Second cell in the row (if available)
//                                        if firstIndex + 1 < watchList.count {
//                                            ThumbnailView(
//                                                viewModel: .init(),
//                                                filmID: watchList[firstIndex + 1].id,
//                                                posterPath: watchList[firstIndex + 1].posterPath,
//                                                width: 150,
//                                                height: 225,
//                                                namespace: namespace
//                                            )
//                                        } else {
//                                            // Optional: add a spacer for layout symmetry if you have an odd number of items.
//                                            Spacer()
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.top, 20)
//                            .padding(.horizontal, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Wheel")
        }
        .onAppear {
            viewModel.addFilmsToWheel(Array(watchList))
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("We have Winner!"),
                message: Text("The winning is \(viewModel.winningName)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func angleForSegment(_ index: Int) -> Angle {
        Angle(degrees: Double(index) / Double(viewModel.names.count) * 360)
    }

    func textAngleForSegment(_ index: Int) -> Angle {
        let segmentAngle = 360.0 / Double(viewModel.names.count)
        return Angle(degrees: -Double(index) * segmentAngle - segmentAngle / 2)
    }
}

extension WatchWheelView {
    class ViewModel: ObservableObject {
        @Published  var segmentCount = 1
        @Published  var rotation: Double = 0
        @Published  var isSpinning = false
        @Published  var winningName: String = ""
        @Published  var showAlert = false
        @Published  var usedColors: [Color] = [.blue]
        @Published  var colors: [Color] = [.gray.opacity(0.3)]
        @Published  var usedColorsNames: [Color] = [.blue]
        @Published  var names: [String] = [""]
        @Published  var winningColor: [String] = []
        @Published  var newColorName: String = ""
        var selectedColor: Color = .blue
        var lastUsedColor: Color = .clear
        let availableColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        let totalSpinDuration: Double = 5.0
        var totalRotations: Double = 3500

        func spinRoulette() {
            guard !isSpinning else { return }
            isSpinning = true

            withAnimation(Animation.timingCurve(0.1, 0.8, 0.3, 1.0, duration: totalSpinDuration)) {
                rotation += totalRotations
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + totalSpinDuration) {[weak self] in
                guard let this = self else {return}
                this.isSpinning = false
                let incompleteRotation = Int(this.rotation) % 360
                let restOfRotation: Double = Double(incompleteRotation) / (360.0 / Double(this.segmentCount))
                let restOfRotationInteger = Int(restOfRotation)
                let winningIndex = Double(restOfRotationInteger) == restOfRotation ? restOfRotationInteger : restOfRotationInteger + 1

                this.winningColor = this.names.reversed()
                this.winningName = this.winningColor[winningIndex - 1]
                this.showAlert = true
            }
        }

        func addFilmsToWheel(_ films: [Film]) {
            films.forEach { film in
                addNewColorAndName(name: film.title ?? "-")
            }

            names.removeAll(where: { $0 == "" })
            segmentCount = names.count
        }

        func addNewItem() {
            guard !newColorName.isEmpty else { return }
            addNewColorAndName(name: newColorName)
            names.removeAll(where: {$0 == ""})
            segmentCount = names.count
            newColorName = ""
        }

        func deleteItems(at offsets: IndexSet) {
            names.remove(atOffsets: offsets)
            segmentCount -= 1
            if names.isEmpty {
                names = [""]
                segmentCount = 1
            }
        }

        func addNewColorAndName(name: String) {
            if usedColors.count < availableColors.count {
                let unusedColors = availableColors.filter { !usedColors.contains($0) }
                if let randomColor = unusedColors.randomElement() {
                    colors.append(randomColor)
                    usedColors.append(randomColor)
                    lastUsedColor = randomColor
                    if availableColors.firstIndex(of: randomColor) != nil {
                        names.append(name)
                    }
                }
            } else {
                if let randomColor = availableColors.filter({$0 != lastUsedColor && $0 != colors[0]}).randomElement() {
                    colors.append(randomColor)
                    lastUsedColor = randomColor
                    if availableColors.firstIndex(of: randomColor) != nil {
                        names.append(name)
                    }
                }
            }
        }
    }
}

struct Segment: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        path.move(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    WatchWheelView()
}
